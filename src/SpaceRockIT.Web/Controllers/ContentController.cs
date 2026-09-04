using Microsoft.AspNetCore.Mvc;

namespace SpaceRockIT.Web.Controllers;

/// <summary>
/// The festival's mostly-static content pages, rebuilt as Razor views.
/// </summary>
/// <remarks>
/// Copy is the real Dutch text from the site (mined 2026-09-01). These pages carry no database
/// data, so there is no service dependency; the programme and speakers live in their own
/// controllers. One action per page keeps the real URLs explicit.
/// </remarks>
public class ContentController : Controller
{
    [Route("nieuws")] public IActionResult Nieuws() { ViewData["Title"] = "Nieuws"; return View(); }
    [Route("tickets")] public IActionResult Tickets() { ViewData["Title"] = "Tickets"; return View(); }
    [Route("media")] public IActionResult Media() { ViewData["Title"] = "Media"; return View(); }
    [Route("locatie")] public IActionResult Locatie() { ViewData["Title"] = "Locatie"; return View(); }
    [Route("faq")] public IActionResult Faq() { ViewData["Title"] = "FAQ"; return View(); }
    [Route("sponsor-worden-ja-graag")] public IActionResult Sponsor() { ViewData["Title"] = "Sponsor worden? Ja graag!"; return View(); }
    [Route("sneakpreview")] public IActionResult SneakPreview() { ViewData["Title"] = "Sneak preview"; return View(); }
    [Route("zelf-een-sessie-organiseren")] public IActionResult OrganiseerSessie() { ViewData["Title"] = "Zelf een sessie organiseren?"; return View(); }
    [Route("spacerockitplanner")] public IActionResult Planner() { ViewData["Title"] = "SpaceRockIT Planner"; return View(); }
    [Route("spacerockitplannerbeheer")] public IActionResult PlannerBeheer() { ViewData["Title"] = "SpaceRockIT Planner beheer"; return View(); }
    [Route("privacybeleid")] public IActionResult Privacy() { ViewData["Title"] = "Privacybeleid"; return View(); }
    [Route("cookiebeleid-eu")] public IActionResult Cookies() { ViewData["Title"] = "Cookiebeleid (EU)"; return View(); }
    [Route("dit-is-een-bericht")] public IActionResult Bericht() { ViewData["Title"] = "Dit is een bericht"; return View(); }
}
