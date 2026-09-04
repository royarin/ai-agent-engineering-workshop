namespace SpaceRockIT.Web.Services;

/// <summary>
/// The web app's only door to the Reviews API — a separate system that owns session reviews
/// and its own database.
/// </summary>
/// <remarks>
/// <para>
/// This client is deliberately almost empty. It has the plumbing (base address, timeout,
/// availability check) but <b>no methods for reading or writing reviews</b>, because the review
/// feature does not exist yet. That gap is the workshop.
/// </para>
/// <para>
/// When reviews are built, they go: ReviewsController → IReviewService → this client → HTTP.
/// The web app must never reach the reviews database directly; it has no connection string for
/// it and no DbContext. See docs/architecture/api-boundaries.md.
/// </para>
/// </remarks>
public class ReviewsApiClient(HttpClient http, ILogger<ReviewsApiClient> logger)
{
    /// <summary>
    /// Whether the Reviews API is reachable right now.
    /// </summary>
    /// <remarks>
    /// Every page that shows review data must call this and degrade gracefully. A dead API
    /// shows an "unavailable" widget; it never blanks the page. On a festival network — and on
    /// stage — the API being briefly unreachable is expected, not exceptional.
    /// </remarks>
    public async Task<bool> IsAvailableAsync(CancellationToken ct = default)
    {
        try
        {
            var response = await http.GetAsync("/health", ct);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
        {
            logger.LogWarning(ex, "Reviews API unreachable at {BaseAddress}", http.BaseAddress);
            return false;
        }
    }
}
