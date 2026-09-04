using System.Reflection;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace SpaceRockIT.Web.Tests;

/// <summary>
/// Guardrails that execute.
/// </summary>
/// <remarks>
/// These are the workshop's Stage-3 point made real: the rule "no data access from a controller"
/// is written in docs/architecture/api-boundaries.md, but a rule you cannot enforce is a wish.
/// This test goes red the moment someone — human or agent — crosses the boundary.
/// </remarks>
public class ArchitectureTests
{
    private static readonly Assembly WebAssembly = typeof(Program).Assembly;

    private static IEnumerable<Type> Controllers => WebAssembly
        .GetTypes()
        .Where(t => typeof(ControllerBase).IsAssignableFrom(t) && !t.IsAbstract);

    [Fact]
    public void Controllers_do_not_depend_on_a_DbContext()
    {
        var offenders = new List<string>();

        foreach (var controller in Controllers)
        {
            var ctorParams = controller
                .GetConstructors()
                .SelectMany(c => c.GetParameters())
                .Select(p => p.ParameterType);

            var fields = controller
                .GetFields(BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public)
                .Select(f => f.FieldType);

            var properties = controller
                .GetProperties(BindingFlags.Instance | BindingFlags.Public)
                .Select(p => p.PropertyType);

            foreach (var type in ctorParams.Concat(fields).Concat(properties))
            {
                if (typeof(DbContext).IsAssignableFrom(type))
                    offenders.Add($"{controller.Name} depends on {type.Name}");
            }
        }

        Assert.True(offenders.Count == 0,
            "Controllers must not touch a DbContext. Go through a service instead " +
            "(Controller -> Service -> Repository/ApiClient -> data). " +
            "See docs/architecture/api-boundaries.md.\n  " +
            string.Join("\n  ", offenders));
    }

    [Fact]
    public void Controllers_depend_only_on_service_interfaces()
    {
        var offenders = new List<string>();

        foreach (var controller in Controllers)
        {
            foreach (var parameter in controller.GetConstructors().SelectMany(c => c.GetParameters()))
            {
                var type = parameter.ParameterType;
                var isOwnType = type.Assembly == WebAssembly;
                if (!isOwnType) continue;                    // framework types are fine

                var isServiceInterface = type is { IsInterface: true }
                                         && type.Namespace?.Contains("Services") == true;
                var isApiClient = type.Name.EndsWith("ApiClient", StringComparison.Ordinal);

                if (!isServiceInterface && !isApiClient)
                    offenders.Add($"{controller.Name} takes {type.Name}");
            }
        }

        Assert.True(offenders.Count == 0,
            "Controllers should take service interfaces, not concrete types or entities.\n  " +
            string.Join("\n  ", offenders));
    }

    [Fact]
    public void Web_app_has_no_Review_entity_of_its_own()
    {
        // Reviews belong to SpaceRockIT.Reviews.Api. If a Review type ever appears in the web
        // app's model or data layer, someone has collapsed the two systems into one.
        var strays = WebAssembly.GetTypes()
            .Where(t => t.Name.Contains("Review", StringComparison.Ordinal))
            .Where(t => t.Namespace?.Contains("Models") == true
                        || t.Namespace?.Contains("Data") == true)
            .Select(t => t.FullName!)
            .ToList();

        Assert.True(strays.Count == 0,
            "The website must not own review data — it calls the Reviews API. Found:\n  " +
            string.Join("\n  ", strays));
    }
}
