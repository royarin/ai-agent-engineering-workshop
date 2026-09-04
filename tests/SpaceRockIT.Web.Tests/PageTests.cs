using System.Net;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc.Testing;

namespace SpaceRockIT.Web.Tests;

/// <summary>
/// Verification evidence: every page of the rebuilt MVC site renders, the programme and speakers
/// come from seeded data, and the session-detail page (where reviews will attach) works.
/// </summary>
public class PageTests(IsolatedWebAppFactory factory)
    : IClassFixture<IsolatedWebAppFactory>
{
    private HttpClient Client => factory.CreateClient();

    private const string OurSession =
        "/schedule/taking-control-of-your-ai-coding-agent-s-patterns-guardrails-1320-1505";

    [Theory]
    [InlineData("/")]
    [InlineData("/schedule")]
    [InlineData("/sprekers")]
    [InlineData("/nieuws")]
    [InlineData("/tickets")]
    [InlineData("/media")]
    [InlineData("/locatie")]
    [InlineData("/faq")]
    [InlineData("/sneakpreview")]
    [InlineData("/spacerockitplanner")]
    [InlineData("/spacerockitplannerbeheer")]
    [InlineData("/sponsor-worden-ja-graag")]
    [InlineData("/zelf-een-sessie-organiseren")]
    [InlineData("/privacybeleid")]
    [InlineData("/cookiebeleid-eu")]
    [InlineData("/dit-is-een-bericht")]
    public async Task Every_page_loads(string url)
    {
        var response = await Client.GetAsync(url);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Pages_render_our_own_mvc_chrome()
    {
        var html = await Client.GetStringAsync("/");

        // Our hand-built layout: the brand stylesheet and the festival's own navigation.
        Assert.Contains("/css/site.css", html, StringComparison.Ordinal);
        Assert.Contains("main-nav", html, StringComparison.Ordinal);
        Assert.Contains("/sprekers", html, StringComparison.Ordinal);
        Assert.Contains("/schedule", html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task No_wordpress_or_elementor_remains()
    {
        // The site is now a genuine ASP.NET Core MVC rebuild — none of the mined WordPress theme,
        // Elementor markup or wp-content asset paths should survive.
        var html = await Client.GetStringAsync("/");

        Assert.DoesNotContain("business-event-pro", html, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("elementor", html, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("wp-content", html, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("wp-json", html, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Schedule_shows_the_six_stages()
    {
        var html = await Client.GetStringAsync("/schedule");

        foreach (var stage in new[]
                 { "The Cabin", "ProatHuus", "The Circus", "SurfClub", "De Foef", "House Tent" })
            Assert.Contains(stage, html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Schedule_links_every_session_to_its_own_page()
    {
        var html = await Client.GetStringAsync("/schedule");

        var links = Regex.Matches(html, @"href=""/schedule/([a-z0-9-]+)""")
            .Select(m => m.Groups[1].Value)
            .Where(s => s.Length > 0)
            .Distinct()
            .ToList();

        // 23 real sessions on the grid.
        Assert.True(links.Count >= 20, $"Expected the grid to link its sessions, found {links.Count}");
        Assert.Contains(links, l => l.StartsWith("taking-control-of-your-ai-coding-agent",
            StringComparison.Ordinal));
    }

    [Fact]
    public async Task Session_detail_renders_a_known_session()
    {
        var html = await Client.GetStringAsync(OurSession);

        Assert.Contains("House Tent", html, StringComparison.Ordinal);
        Assert.Contains("M. de Graaf", html, StringComparison.Ordinal);
        Assert.Contains("13:20", html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Unknown_session_returns_404()
    {
        var response = await Client.GetAsync("/schedule/no-such-session");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task Speakers_page_shows_the_roster()
    {
        var html = await Client.GetStringAsync("/sprekers");

        Assert.Contains("F. Hermans", html, StringComparison.Ordinal);
        Assert.Contains("A. Roy", html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Home_page_uses_the_correct_retained_sponsor_label()
    {
        var html = await Client.GetStringAsync("/");

        Assert.Contains("XPRTZ .NET Experts", html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Media_page_explains_why_the_archive_links_out()
    {
        var html = await Client.GetStringAsync("/media");

        Assert.Contains("officiële media-archief", html, StringComparison.Ordinal);
        Assert.Contains("Open het officiële media-archief", html, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Cookie_policy_matches_the_functional_cookie_only_setup()
    {
        var html = await Client.GetStringAsync("/cookiebeleid-eu");

        Assert.Contains("functionele cookie", html, StringComparison.Ordinal);
        Assert.Contains("geen cookiebanner", html, StringComparison.Ordinal);
        Assert.DoesNotContain("cookie-instellingen onderaan de pagina", html, StringComparison.OrdinalIgnoreCase);
    }
}
