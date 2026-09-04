using Microsoft.EntityFrameworkCore;
using SpaceRockIT.Web.Data;
using SpaceRockIT.Web.ViewModels;

namespace SpaceRockIT.Web.Services;

/// <summary>Reads the speaker roster and their sessions.</summary>
public interface ISpeakerService
{
    /// <summary>All speakers, keynote first, then alphabetically by name.</summary>
    Task<SpeakersViewModel> GetSpeakersAsync(CancellationToken ct = default);
}

/// <inheritdoc cref="ISpeakerService"/>
public class SpeakerService(SiteDbContext db) : ISpeakerService
{
    /// <inheritdoc />
    public async Task<SpeakersViewModel> GetSpeakersAsync(CancellationToken ct = default)
    {
        var speakers = await db.Speakers
            .Include(s => s.SessionSpeakers).ThenInclude(ss => ss.Session)
            .AsNoTracking()
            .ToListAsync(ct);

        var ordered = speakers
            .OrderByDescending(s => s.IsKeynote)
            .ThenBy(s => s.Name, StringComparer.CurrentCulture)
            .Select(s => new SpeakerDetail(
                s.Id,
                s.Name,
                s.IsKeynote,
                Localized.PickNullable(s.Bio, s.BioEn),
                s.PhotoFile,
                s.SessionSpeakers
                    .Where(ss => ss.Session is not null && !ss.Session.IsBreak)
                    .Select(ss => new SessionCard(
                        ss.Session!.Id, Localized.Pick(ss.Session.Title, ss.Session.TitleEn),
                        ss.Session.Format, false, []))
                    .ToList()))
            .ToList();

        return new SpeakersViewModel(ordered);
    }
}
