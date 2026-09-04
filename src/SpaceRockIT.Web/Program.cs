using System.Globalization;
using Microsoft.AspNetCore.Localization;
using Microsoft.EntityFrameworkCore;
using SpaceRockIT.Web.Data;
using SpaceRockIT.Web.Services;

var builder = WebApplication.CreateBuilder(args);

// The site is bilingual: Dutch (default, the festival's native language) and English, so the
// workshop can be delivered to a non-Dutch audience. UI copy lives in Resources/SharedResource.*.resx.
builder.Services.AddLocalization(o => o.ResourcesPath = "Resources");
builder.Services.AddControllersWithViews().AddViewLocalization();

// Dutch first; the chosen language is remembered in a cookie (set by CultureController).
var supportedCultures = new[] { new CultureInfo("nl"), new CultureInfo("en") };
builder.Services.Configure<RequestLocalizationOptions>(o =>
{
    o.DefaultRequestCulture = new RequestCulture("nl");
    o.SupportedCultures = supportedCultures;
    o.SupportedUICultures = supportedCultures;

    // Language is chosen explicitly and remembered in a cookie — the site does not silently follow
    // the browser's Accept-Language, so a Dutch festival page stays Dutch until the visitor opts in.
    o.RequestCultureProviders = new List<IRequestCultureProvider>
    {
        new QueryStringRequestCultureProvider(),
        new CookieRequestCultureProvider()
    };
});

// The site's own database: programme, speakers, page copy. Not reviews — those live in
// SpaceRockIT.Reviews.Api, and this app has no connection to that database by design.
builder.Services.AddDbContext<SiteDbContext>(o =>
    o.UseSqlite(builder.Configuration.GetConnectionString("Site") ?? "Data Source=site.db"));

builder.Services.AddScoped<IScheduleService, ScheduleService>();
builder.Services.AddScoped<ISpeakerService, SpeakerService>();

// The only route to the Reviews API. Short timeout on purpose: on a festival network a slow
// API must degrade to "reviews unavailable" quickly, not hold the page hostage.
builder.Services.AddHttpClient<ReviewsApiClient>(c =>
{
    c.BaseAddress = new Uri(builder.Configuration["ReviewsApi:BaseUrl"]
                            ?? "http://localhost:5081");
    c.Timeout = TimeSpan.FromSeconds(3);
});

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseStaticFiles();
app.UseRouting();

// Applies the culture from the cookie (or the Dutch default) to every request before the
// controllers and views resolve their localized strings.
app.UseRequestLocalization();

// Every page route is an explicit [Route] attribute on its controller action, so the real
// site's URLs (/sprekers, /nieuws, /sponsor-worden-ja-graag, ...) are matched exactly.
app.MapControllers();

// Create and seed the database on startup so a clean clone shows a working site immediately.
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<SiteDbContext>();
    var env = scope.ServiceProvider.GetRequiredService<IWebHostEnvironment>();
    await SeedData.EnsureSeededAsync(db, env);
}

app.Run();

/// <summary>Exposed so WebApplicationFactory can host this app in tests.</summary>
public partial class Program;
