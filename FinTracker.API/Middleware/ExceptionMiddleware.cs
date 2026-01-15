using Microsoft.AspNetCore.Mvc;
using System.Net;
using System.Text.Json;

namespace FinTracker.API.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;
        private readonly IHostEnvironment _env;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger, IHostEnvironment env)
        {
            _next = next;
            _logger = logger;
            _env = env;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                await HandleExceptionAsync(context, ex);
            }
        }

        private async Task HandleExceptionAsync(HttpContext context, Exception ex)
        {
            context.Response.ContentType = "application/json";

            var response = new ProblemDetails
            {
                Instance = context.Request.Path
            };

            switch (ex)
            {
                case UnauthorizedAccessException:
                    context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                    response.Status = (int)HttpStatusCode.Unauthorized;
                    response.Title = "Brak autoryzacji";
                    response.Detail = ex.Message;
                    break;

                case KeyNotFoundException:
                case FileNotFoundException:
                    context.Response.StatusCode = (int)HttpStatusCode.NotFound;
                    response.Status = (int)HttpStatusCode.NotFound;
                    response.Title = "Nie znaleziono zasobu";
                    response.Detail = ex.Message;
                    break;

                case ArgumentException:
                case InvalidOperationException:
                    context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                    response.Status = (int)HttpStatusCode.BadRequest;
                    response.Title = "Błąd żądania";
                    response.Detail = ex.Message;
                    break;

                default:
                    context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    response.Status = (int)HttpStatusCode.InternalServerError;
                    response.Title = "Wystąpił błąd serwera";

                    response.Detail = _env.IsDevelopment() ? ex.Message : "Wystąpił nieoczekiwany błąd. Spróbuj ponownie później.";
                    break;
            }

            var jsonOptions = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
            var json = JsonSerializer.Serialize(response, jsonOptions);

            await context.Response.WriteAsync(json);
        }
    }
}