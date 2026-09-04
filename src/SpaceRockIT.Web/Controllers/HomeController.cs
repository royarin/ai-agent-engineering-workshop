using Microsoft.AspNetCore.Mvc;

namespace SpaceRockIT.Web.Controllers;

/// <summary>The festival home page, plus error handling.</summary>
public class HomeController : Controller
{
    [Route("/")]
    public IActionResult Index() => View();

    [Route("Home/Error")]
    public IActionResult Error() => View("~/Views/Shared/Error.cshtml");
}
