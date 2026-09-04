using Microsoft.AspNetCore.Mvc;
using SpaceRockIT.Web.Services;

namespace SpaceRockIT.Web.Controllers;

/// <summary>
/// The programme: the day grid, and the per-session detail page.
/// </summary>
/// <remarks>
/// Thin by design. No data access here; it all goes through <see cref="IScheduleService"/>,
/// which an architecture test enforces. The session detail page is where reviews will attach.
/// </remarks>
public class ScheduleController(IScheduleService schedule) : Controller
{
    [Route("schedule")]
    public async Task<IActionResult> Index(CancellationToken ct)
    {
        ViewData["Title"] = "Schedule";
        return View(await schedule.GetScheduleAsync(ct));
    }

    /// <summary>One session. Not present on the real site — added because a review needs a home.</summary>
    [Route("schedule/{id}")]
    public async Task<IActionResult> Session(string id, CancellationToken ct)
    {
        var session = await schedule.GetSessionAsync(id, ct);
        if (session is null) return NotFound();
        ViewData["Title"] = session.Title;
        return View(session);
    }
}
