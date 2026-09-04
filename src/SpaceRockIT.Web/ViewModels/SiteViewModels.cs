namespace SpaceRockIT.Web.ViewModels;

// Views bind to these, never to entities. Keeping the two apart means a change to the
// database shape does not silently change what a page renders.

/// <summary>One cell in the schedule grid.</summary>
public record SessionCard(
    string Id,
    string Title,
    string Format,
    bool IsBreak,
    List<string> SpeakerNames);

/// <summary>
/// One row of the schedule: a time slot, either with a single full-width item
/// (<paramref name="Plenary"/>) or one cell per stage.
/// </summary>
public record ScheduleRow(
    string Start,
    string End,
    bool IsPlenary,
    SessionCard? Plenary,
    List<SessionCard?> ByStage);

/// <summary>The whole day grid.</summary>
public record ScheduleViewModel(
    List<string> StageNames,
    List<ScheduleRow> Rows);

public record SpeakerSummary(string Id, string Name, string? PhotoFile);

/// <summary>
/// The session detail page — the page reviews belong on.
/// </summary>
public record SessionDetailViewModel(
    string Id,
    string Title,
    string? Description,
    string? StageName,
    string Start,
    string End,
    string Format,
    List<SpeakerSummary> Speakers);

public record SpeakerDetail(
    string Id,
    string Name,
    bool IsKeynote,
    string? Bio,
    string? PhotoFile,
    List<SessionCard> Sessions);

public record SpeakersViewModel(List<SpeakerDetail> Speakers);

public record PageViewModel(string Key, string Title, string? Body);
