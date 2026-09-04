using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;

namespace SpaceRockIT.Web.Tests;

/// <summary>
/// A test host with its own private SQLite database.
/// </summary>
/// <remarks>
/// The default <see cref="WebApplicationFactory{Program}"/> lets every test class point at the same
/// on-disk <c>site.db</c>. xUnit runs test classes in parallel, so two hosts would race to create
/// and seed that file on a clean clone's first <c>dotnet test</c> — intermittently 500-ing pages
/// whose seeding lost the race. Each factory instead gets a unique database file, deleted on
/// dispose, so the web test classes are fully isolated from one another.
/// </remarks>
public sealed class IsolatedWebAppFactory : WebApplicationFactory<Program>
{
    private readonly string _dbPath =
        Path.Combine(Path.GetTempPath(), $"spacerockit-test-{Guid.NewGuid():N}.db");

    protected override void ConfigureWebHost(IWebHostBuilder builder) =>
        builder.UseSetting("ConnectionStrings:Site", $"Data Source={_dbPath}");

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        if (!disposing) return;

        // SQLite also writes -wal and -shm sidecars; remove them too. Best effort.
        var dir = Path.GetDirectoryName(_dbPath)!;
        foreach (var file in Directory.EnumerateFiles(dir, Path.GetFileName(_dbPath) + "*"))
        {
            try { File.Delete(file); } catch { /* the OS will reclaim a stray temp file */ }
        }
    }
}
