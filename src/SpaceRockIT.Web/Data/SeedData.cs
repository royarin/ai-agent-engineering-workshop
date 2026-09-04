using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using SpaceRockIT.Web.Models;

namespace SpaceRockIT.Web.Data;

/// <summary>
/// Populates the site database from the mined seed files in wwwroot/seed on first run,
/// so a clean clone shows a working festival site with no setup steps.
/// </summary>
/// <remarks>
/// The seed files in wwwroot/seed are the hand-maintained source of truth. They originated from a
/// 2026-09-01 capture of www.spacerockitfestival.nl (see workshop-meta-docs/mined/), but the mining
/// pipeline and the raw snapshot have since been removed, and the speaker names, bios and photos are
/// anonymised (a shared placeholder image, initials + surname) so no real person's data is shipped.
/// </remarks>
public static class SeedData
{
    private static readonly JsonSerializerOptions Json =
        new() { PropertyNameCaseInsensitive = true };

    public static async Task EnsureSeededAsync(SiteDbContext db, IWebHostEnvironment env)
    {
        await db.Database.EnsureCreatedAsync();
        if (await db.Sessions.AnyAsync()) return;

        var dir = Path.Combine(env.WebRootPath, "seed");

        var stages = Read<StageSeed>(dir, "stages.json");
        var slots = Read<SlotSeed>(dir, "slots.json");
        var sessions = Read<SessionSeed>(dir, "sessions.json");
        var speakers = Read<SpeakerSeed>(dir, "speakers.json");
        var pages = Read<PageSeed>(dir, "pages.json");

        db.Stages.AddRange(stages.Select(s => new Stage
        {
            Id = s.Id, Name = s.Name, Order = s.Order
        }));

        db.Slots.AddRange(slots.Select(s => new Slot
        {
            Id = s.Id, Start = s.Start, End = s.End ?? "", Kind = s.Kind
        }));

        db.Speakers.AddRange(speakers.Select(s => new Speaker
        {
            Id = s.Id, Name = s.Name, IsKeynote = s.IsKeynote,
            Bio = s.Bio, BioEn = s.BioEn, PhotoFile = s.PhotoFile
        }));

        var speakerIds = speakers.Select(s => s.Id).ToHashSet();

        foreach (var s in sessions)
        {
            db.Sessions.Add(new Session
            {
                Id = s.Id,
                Title = s.Title,
                Description = s.Description ?? DescriptionFor(s, speakers),
                TitleEn = s.TitleEn,
                DescriptionEn = s.DescriptionEn,
                StageId = s.StageId,
                SlotId = s.SlotId,
                Start = s.Start,
                End = s.End ?? "",
                Format = s.Format,
                IsBreak = s.IsBreak,
            });

            foreach (var sid in (s.SpeakerIds ?? []).Distinct().Where(speakerIds.Contains))
                db.SessionSpeakers.Add(new SessionSpeaker { SessionId = s.Id, SpeakerId = sid });
        }

        db.Pages.AddRange(pages.Select(p => new PageContent
        {
            Key = p.Key, Title = p.Title, Path = p.Path
        }));

        await db.SaveChangesAsync();
    }

    /// <summary>
    /// The mined schedule carries no session descriptions — those live on the speakers page as
    /// free-text blurbs. Match a blurb to its session by title prefix, and leave the description
    /// null when there is no confident match rather than attaching the wrong text.
    /// </summary>
    private static string? DescriptionFor(SessionSeed session, List<SpeakerSeed> speakers)
    {
        if (session.IsBreak || string.IsNullOrWhiteSpace(session.Title)) return null;

        var key = Normalise(session.Title);
        if (key.Length < 12) return null;   // too short to match safely

        foreach (var sp in speakers.Where(s => (session.SpeakerIds ?? []).Contains(s.Id)))
        {
            var blurbs = sp.SessionBlurbs ?? [];
            for (var i = 0; i < blurbs.Count; i++)
            {
                if (!Normalise(blurbs[i]).StartsWith(key[..Math.Min(key.Length, 30)],
                        StringComparison.Ordinal))
                    continue;

                // The lines after the title, up to the "HH:MM locatie" footer, are the description.
                var body = blurbs.Skip(i + 1)
                    .TakeWhile(l => !System.Text.RegularExpressions.Regex.IsMatch(
                        l, @"^\d{1,2}:\d{2}\s+locatie"))
                    .Where(l => !l.StartsWith("Samen met", StringComparison.OrdinalIgnoreCase))
                    .ToList();

                var text = string.Join("\n\n", body).Trim();
                if (text.Length > 40) return text;
            }
        }
        return null;
    }

    private static string Normalise(string s) =>
        new(s.ToLowerInvariant().Where(c => char.IsLetterOrDigit(c) || c == ' ').ToArray());

    private static List<T> Read<T>(string dir, string file)
    {
        var path = Path.Combine(dir, file);
        if (!File.Exists(path))
            throw new FileNotFoundException(
                $"Seed file missing: {path}. The seed files live in wwwroot/seed.", path);
        return JsonSerializer.Deserialize<List<T>>(File.ReadAllText(path), Json) ?? [];
    }

    // Shapes of the mined JSON. Separate from the entities on purpose: the seed format is an
    // external contract that can drift, and we want a compile error here rather than silent nulls.
    private sealed record StageSeed(string Id, string Name, int Order);
    private sealed record SlotSeed(string Id, string Start, string? End, string Kind);
    private sealed record SessionSeed(
        string Id, string Title, string? Description, string? StageId, string SlotId,
        string Start, string? End, string Format, bool IsBreak, List<string>? SpeakerIds,
        string? TitleEn = null, string? DescriptionEn = null);
    private sealed record SpeakerSeed(
        string Id, string Name, bool IsKeynote, string? Bio, string? PhotoFile,
        List<string>? SessionBlurbs, string? BioEn = null);
    private sealed record PageSeed(string Key, string Title, string Path);
}
