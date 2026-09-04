using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;

namespace SpaceRockIT.Web.Controllers;

/// <summary>
/// Switches the site language. Sets the culture cookie the request-localization middleware reads,
/// then returns the visitor to the page they were on so the choice is seamless and persists.
/// </summary>
public class CultureController : Controller
{
    private static readonly HashSet<string> Supported = new(StringComparer.OrdinalIgnoreCase)
        { "nl", "en" };

    [HttpGet("set-language")]
    public IActionResult Set(string culture, string? returnUrl)
    {
        if (!Supported.Contains(culture)) culture = "nl";

        Response.Cookies.Append(
            CookieRequestCultureProvider.DefaultCookieName,
            CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(culture)),
            new CookieOptions
            {
                Expires = DateTimeOffset.UtcNow.AddYears(1),
                IsEssential = true,       // functional, not tracking — no consent needed
                Path = "/",
                SameSite = SameSiteMode.Lax
            });

        // Only ever redirect to a local path, so the return URL cannot be an open redirect.
        return LocalRedirect(Url.IsLocalUrl(returnUrl) ? returnUrl! : "/");
    }
}
