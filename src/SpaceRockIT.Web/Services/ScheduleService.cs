using Microsoft.EntityFrameworkCore;
using SpaceRockIT.Web.Data;
using SpaceRockIT.Web.ViewModels;

namespace SpaceRockIT.Web.Services;

/// <summary>
/// Reads the festival programme for the schedule and session pages.
/// </summary>
/// <remarks>
/// Controllers depend on this interface, never on <see cref="SiteDbContext"/>.
/// See docs/architecture/api-boundaries.md — no data access from a controller.
/// </remarks>
public interface IScheduleService
{
    /// <summary>The full day grid: every slot, with its sessions arranged by stage.</summary>
    Task<ScheduleViewModel> GetScheduleAsync(CancellationToken ct = default);

    /// <summary>One session with its stage, slot and speakers, or null if the id is unknown.</summary>
    Task<SessionDetailViewModel?> GetSessionAsync(string id, CancellationToken ct = default);
}

/// <inheritdoc cref="IScheduleService"/>
public class ScheduleService(SiteDbContext db) : IScheduleService
{
    /// <inheritdoc />
    public async Task<ScheduleViewModel> GetScheduleAsync(CancellationToken ct = default)
    {
        var stages = await db.Stages.OrderBy(s => s.Order).AsNoTracking().ToListAsync(ct);

        var sessions = await db.Sessions
            .Include(s => s.SessionSpeakers).ThenInclude(ss => ss.Speaker)
            .AsNoTracking()
            .ToListAsync(ct);

        var slots = await db.Slots.AsNoTracking().ToListAsync(ct);

        var rows = slots
            .OrderBy(s => TimeOrder(s.Start))
            .Select(slot =>
            {
                var inSlot = sessions.Where(s => s.SlotId == slot.Id).ToList();
                return new ScheduleRow(
                    slot.Start,
                    slot.End,
                    slot.Kind == "plenary",
                    inSlot.FirstOrDefault(s => s.StageId is null) is { } plenary
                        ? Card(plenary)
                        : null,
                    stages.Select(st =>
                        inSlot.FirstOrDefault(s => s.StageId == st.Id) is { } cell
                            ? Card(cell)
                            : null).ToList());
            })
            .ToList();

        return new ScheduleViewModel(
            stages.Select(s => s.Name).ToList(),
            rows);
    }

    /// <inheritdoc />
    public async Task<SessionDetailViewModel?> GetSessionAsync(string id, CancellationToken ct = default)
    {
        var session = await db.Sessions
            .Include(s => s.Stage)
            .Include(s => s.SessionSpeakers).ThenInclude(ss => ss.Speaker)
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Id == id, ct);

        if (session is null) return null;

        return new SessionDetailViewModel(
            session.Id,
            Localized.Pick(session.Title, session.TitleEn),
            Localized.PickNullable(session.Description, session.DescriptionEn),
            session.Stage?.Name,
            session.Start,
            session.End,
            session.Format,
            session.SessionSpeakers
                .Where(ss => ss.Speaker is not null)
                .Select(ss => new SpeakerSummary(
                    ss.Speaker!.Id, ss.Speaker.Name, ss.Speaker.PhotoFile))
                .ToList());
    }

    private static SessionCard Card(Models.Session s) => new(
        s.Id,
        Localized.Pick(s.Title, s.TitleEn),
        s.Format,
        s.IsBreak,
        s.SessionSpeakers
            .Where(ss => ss.Speaker is not null)
            .Select(ss => ss.Speaker!.Name)
            .ToList());

    /// <summary>
    /// Sorts the evening programme after the daytime one. The site's own schedule runs past
    /// midnight and writes those times as "0:25" and "0:30", so a plain string sort would put
    /// the after-party at breakfast.
    /// </summary>
    private static int TimeOrder(string hhmm)
    {
        var parts = hhmm.Split(':');
        if (parts.Length != 2 || !int.TryParse(parts[0], out var h)
                              || !int.TryParse(parts[1], out var m))
            return int.MaxValue;
        if (h < 6) h += 24;
        return h * 60 + m;
    }
}
