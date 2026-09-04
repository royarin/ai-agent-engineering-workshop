using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace SpaceRockIT.Reviews.Api.Tests;

/// <summary>
/// The Reviews API starts as a running shell: health responds, the schema exists,
/// and there is nothing else. These tests pin that starting state.
/// </summary>
public class ApiTests(WebApplicationFactory<Program> factory)
    : IClassFixture<WebApplicationFactory<Program>>
{
    private HttpClient Client => factory.CreateClient();

    [Fact]
    public async Task Health_responds()
    {
        var response = await Client.GetAsync("/health");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Health_leaks_nothing_internal()
    {
        var body = await Client.GetStringAsync("/health");

        foreach (var leak in new[] { "ConnectionString", "Data Source", "MachineName", "Path" })
            Assert.DoesNotContain(leak, body, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task No_review_endpoints_exist_yet()
    {
        // The seam, on the API side. Building these is Stage 4.
        foreach (var url in new[] { "/reviews", "/api/reviews", "/sessions/x/reviews" })
        {
            var response = await Client.GetAsync(url);
            Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        }
    }
}
