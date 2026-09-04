var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

// The website calls this API from the browser's origin, so it needs to be allowed through.
builder.Services.AddCors(o => o.AddDefaultPolicy(p => p
    .WithOrigins(builder.Configuration["Web:BaseUrl"] ?? "http://localhost:5080")
    .AllowAnyHeader()
    .AllowAnyMethod()));

var app = builder.Build();

app.UseCors();
app.MapControllers();

app.Run();

/// <summary>Exposed so WebApplicationFactory can host this API in tests.</summary>
public partial class Program;
