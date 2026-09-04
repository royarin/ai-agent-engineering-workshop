namespace SpaceRockIT.Web.Models;

/// <summary>
/// A stage (tent) at the festival. There are six: The Cabin, ProatHuus, The Circus,
/// SurfClub, De Foef and House Tent.
/// </summary>
public class Stage
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public int Order { get; set; }

    public List<Session> Sessions { get; set; } = [];
}

/// <summary>
/// A time slot in the programme. A slot is either <c>parallel</c> (six stages run their own
/// session) or <c>plenary</c> (one item spans the whole festival — a break, the keynote,
/// the evening programme).
/// </summary>
public class Slot
{
    public string Id { get; set; } = "";
    public string Start { get; set; } = "";
    public string End { get; set; } = "";
    public string Kind { get; set; } = "parallel";

    public List<Session> Sessions { get; set; } = [];
}

/// <summary>
/// A single programme item.
/// </summary>
/// <remarks>
/// <see cref="Id"/> deliberately includes the slot (e.g. <c>sketchnoting-1115-1200</c>) because
/// three sessions share the title "Sketchnoting" across different slots. Identity is the
/// occurrence, not the title — reviews attach here, and collapsing them would show one
/// session's reviews on all three.
/// </remarks>
public class Session
{
    public string Id { get; set; } = "";
    public string Title { get; set; } = "";
    public string? Description { get; set; }

    /// <summary>English copy. Null falls back to the Dutch <see cref="Title"/> / <see cref="Description"/>.</summary>
    public string? TitleEn { get; set; }
    /// <inheritdoc cref="TitleEn"/>
    public string? DescriptionEn { get; set; }

    public string? StageId { get; set; }
    public Stage? Stage { get; set; }

    public string SlotId { get; set; } = "";
    public Slot? Slot { get; set; }

    public string Start { get; set; } = "";
    public string End { get; set; } = "";

    /// <summary>session | workshop | keynote | plenary</summary>
    public string Format { get; set; } = "session";

    /// <summary>Breaks, lunch and "doors open" are on the grid but are not sessions.</summary>
    public bool IsBreak { get; set; }

    public List<SessionSpeaker> SessionSpeakers { get; set; } = [];
}

/// <summary>A speaker, with the bio and photo shown on the speakers page.</summary>
public class Speaker
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public bool IsKeynote { get; set; }
    public string? Bio { get; set; }

    /// <summary>English bio. Null falls back to the Dutch <see cref="Bio"/>.</summary>
    public string? BioEn { get; set; }

    public string? PhotoFile { get; set; }

    public List<SessionSpeaker> SessionSpeakers { get; set; } = [];
}

/// <summary>Join entity: sessions can have several speakers, speakers several sessions.</summary>
public class SessionSpeaker
{
    public string SessionId { get; set; } = "";
    public Session? Session { get; set; }

    public string SpeakerId { get; set; } = "";
    public Speaker? Speaker { get; set; }
}

/// <summary>Copy for the mostly-static content pages (home, tickets, FAQ, locatie, ...).</summary>
public class PageContent
{
    public string Key { get; set; } = "";
    public string Title { get; set; } = "";
    public string Path { get; set; } = "";
    public string? Body { get; set; }
}
