using Microsoft.AspNetCore.Mvc;
using SpaceRockIT.Web.Services;

namespace SpaceRockIT.Web.Controllers;

/// <summary>The speaker roster. Thin: all data comes through <see cref="ISpeakerService"/>.</summary>
public class SpeakersController(ISpeakerService speakers) : Controller
{
    [Route("sprekers")]
    public async Task<IActionResult> Index(CancellationToken ct)
    {
        ViewData["Title"] = "Sprekers";
        return View(await speakers.GetSpeakersAsync(ct));
    }
}
