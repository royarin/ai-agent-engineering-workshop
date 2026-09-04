using System.Globalization;

namespace SpaceRockIT.Web.Services;

/// <summary>
/// Picks the culture-appropriate copy for seeded content (programme titles, session descriptions,
/// speaker bios). UI chrome is localized through resx; this is for the *data*, which carries its
/// own optional English fields with Dutch as the fallback.
/// </summary>
/// <remarks>
/// Reads <see cref="CultureInfo.CurrentUICulture"/>, which the request-localization middleware sets
/// per request before a service runs. The rule stays in the service layer, not the views.
/// </remarks>
internal static class Localized
{
    private static bool IsEnglish =>
        CultureInfo.CurrentUICulture.TwoLetterISOLanguageName.Equals("en", StringComparison.OrdinalIgnoreCase);

    /// <summary>English when the culture is English and an English value exists; otherwise Dutch.</summary>
    public static string Pick(string nl, string? en) =>
        IsEnglish && !string.IsNullOrWhiteSpace(en) ? en! : nl;

    /// <inheritdoc cref="Pick(string,string?)"/>
    public static string? PickNullable(string? nl, string? en) =>
        IsEnglish && !string.IsNullOrWhiteSpace(en) ? en : nl;
}
