using Microsoft.EntityFrameworkCore;
using SpaceRockIT.Web.Models;

namespace SpaceRockIT.Web.Data;

/// <summary>
/// The festival site's own database: programme, speakers and page copy.
/// </summary>
/// <remarks>
/// This context knows nothing about reviews. Reviews are owned by SpaceRockIT.Reviews.Api,
/// a separate system with its own database, reached over HTTP through the service layer.
/// Adding a Review entity here would be architecturally wrong — see
/// docs/architecture/api-boundaries.md.
/// </remarks>
public class SiteDbContext(DbContextOptions<SiteDbContext> options) : DbContext(options)
{
    public DbSet<Stage> Stages => Set<Stage>();
    public DbSet<Slot> Slots => Set<Slot>();
    public DbSet<Session> Sessions => Set<Session>();
    public DbSet<Speaker> Speakers => Set<Speaker>();
    public DbSet<SessionSpeaker> SessionSpeakers => Set<SessionSpeaker>();
    public DbSet<PageContent> Pages => Set<PageContent>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<Stage>().HasKey(x => x.Id);
        b.Entity<Slot>().HasKey(x => x.Id);
        b.Entity<Speaker>().HasKey(x => x.Id);
        b.Entity<PageContent>().HasKey(x => x.Key);

        b.Entity<Session>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasOne(x => x.Stage).WithMany(s => s.Sessions).HasForeignKey(x => x.StageId);
            e.HasOne(x => x.Slot).WithMany(s => s.Sessions).HasForeignKey(x => x.SlotId);
        });

        b.Entity<SessionSpeaker>(e =>
        {
            e.HasKey(x => new { x.SessionId, x.SpeakerId });
            e.HasOne(x => x.Session).WithMany(s => s.SessionSpeakers).HasForeignKey(x => x.SessionId);
            e.HasOne(x => x.Speaker).WithMany(s => s.SessionSpeakers).HasForeignKey(x => x.SpeakerId);
        });
    }
}
