using Microsoft.AspNetCore.Mvc;

namespace SpaceRockIT.Reviews.Api.Controllers;

/// <summary>
/// Liveness check. SpaceRockIT.Web calls this to decide whether to show the review widget
/// or an "unavailable" state — a dead API must never blank a page.
/// </summary>
/// <remarks>
/// Returns only safe operational information: no environment values, hostnames, paths,
/// connection strings or versions of anything internal.
/// </remarks>
[ApiController]
[Route("health")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get() => Ok(new { status = "ok", service = "reviews" });
}
