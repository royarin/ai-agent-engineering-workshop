using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace SpaceRockIT.Web.Tests;

/// <summary>
/// The site is bilingual (Dutch default, English on demand). These pin that behaviour so a future
/// change cannot silently drop a language or flip the default.
/// </summary>
public class LocalizationTests(IsolatedWebAppFactory factory)
    : IClassFixture<IsolatedWebAppFactory>
{
    // Client that does not follow the redirect, so we can inspect /set-language's response.
    private HttpClient Client => factory.CreateClient(
        new WebApplicationFactoryClientOptions { AllowAutoRedirect = false });

    private HttpClient Following => factory.CreateClient();

    private static HttpRequestMessage WithCulture(string url, string culture)
    {
        var req = new HttpRequestMessage(HttpMethod.Get, url);
        // The cookie format CookieRequestCultureProvider reads.
        req.Headers.Add("Cookie", $".AspNetCore.Culture=c={culture}|uic={culture}");
        return req;
    }

    [Fact]
    public async Task Default_language_is_Dutch()
    {
        var html = await Following.GetStringAsync("/");

        Assert.Contains("Sprekers", html, StringComparison.Ordinal);
        Assert.Contains("Wat gaan we doen?", html, StringComparison.Ordinal);
        Assert.DoesNotContain("What are we going to do?", html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task English_is_served_when_the_culture_cookie_says_so()
    {
        var response = await Following.SendAsync(WithCulture("/", "en"));
        var html = await response.Content.ReadAsStringAsync();

        Assert.Contains("Speakers", html, StringComparison.Ordinal);
        Assert.Contains("What are we going to do?", html, StringComparison.Ordinal);
        Assert.Contains("lang=\"en\"", html, StringComparison.Ordinal);
    }

    [Theory]
    [InlineData("en")]
    [InlineData("nl")]
    public async Task Set_language_stores_the_cookie_and_redirects_back(string culture)
    {
        var response = await Client.GetAsync($"/set-language?culture={culture}&returnUrl=%2Fsprekers");

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        Assert.Equal("/sprekers", response.Headers.Location?.OriginalString);
        Assert.Contains(response.Headers.GetValues("Set-Cookie"),
            c => c.Contains(".AspNetCore.Culture") && c.Contains($"uic%3D{culture}"));
    }

    [Fact]
    public async Task Set_language_ignores_a_non_local_return_url()
    {
        var response = await Client.GetAsync("/set-language?culture=en&returnUrl=https://evil.example/");

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        Assert.Equal("/", response.Headers.Location?.OriginalString);
    }

    // The seeded programme and speaker bios are DATA (not resx UI strings): they carry optional
    // English fields with Dutch as the fallback, picked per request in the service layer.
    private const string KeynoteSession =
        "/schedule/ai-liet-me-aan-alles-twijfelen-over-programmeren-1000-1100";

    [Fact]
    public async Task Seeded_session_is_Dutch_by_default()
    {
        var html = await Following.GetStringAsync(KeynoteSession);

        Assert.Contains("AI liet me aan alles twijfelen", html, StringComparison.Ordinal);
        Assert.DoesNotContain("AI made me doubt everything", html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Seeded_session_title_and_description_switch_to_English()
    {
        var response = await Following.SendAsync(WithCulture(KeynoteSession, "en"));
        var html = await response.Content.ReadAsStringAsync();

        Assert.Contains("AI made me doubt everything about programming", html, StringComparison.Ordinal);
        Assert.Contains("What is AI? What is AI for", html, StringComparison.Ordinal);
        Assert.DoesNotContain("AI liet me aan alles twijfelen", html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Speaker_bio_switches_to_English()
    {
        var response = await Following.SendAsync(WithCulture("/sprekers", "en"));
        var html = await response.Content.ReadAsStringAsync();

        Assert.Contains("professor of computer-science education", html, StringComparison.Ordinal);
        Assert.DoesNotContain("hoogleraar didactiek van de informatica", html, StringComparison.Ordinal);
    }
}
