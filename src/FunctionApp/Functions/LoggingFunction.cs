using Bogus;
using FunctionApp.Services;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

public class LoggingFunction
{
    private readonly IConfigurationRoot _config;
    private readonly Faker _faker;
    private readonly ILogger<LoggingFunction> _logger;

    public LoggingFunction(IConfigurationRoot configuration,
        ILoggerFactory loggerFactory)
    {
        _config = configuration;
        _faker = new Faker();
        _logger = loggerFactory.CreateLogger<LoggingFunction>();
    }

    [Function(nameof(LoggingFunction))]
#if RELEASE
    public async Task RunAsync([TimerTrigger("0 */10 * * * *")] TimerInfo timerInfo)
#elif DEBUG
    public async Task RunAsync([TimerTrigger("0 */1 * * * *")] TimerInfo timerInfo)
#endif
    {
        if (!_config.GetValue<bool>("ENABLE_LOGGING"))
        {
            return;
        }
        if (DateTime.UtcNow > _config.GetValue<DateTime>("END_DATE"))
        {
            return;
        }

        _logger.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
        var dbCount = _config.GetValue<int>("DATABASE_COUNT");

        var message = _faker.Rant.Review();

        for (int index = 1; index <= dbCount; index++)
        {
            try
            {
                var logDb = new DatabaseLogger(_config, index);
                var lastLog = await logDb.GetLastLogAsync();

                if (lastLog != null)
                {
                    _logger.LogInformation("Most Recent had Id of {logId}, Message of '{message}' and Date of '{date}'", lastLog.LogId, lastLog.LogText, lastLog.LogDate);
                }

                var logEntry = await logDb.LogAsync(message);

                _logger.LogInformation("Added Log with Id of {logId}, Message of '{message}' and Date of '{date}'", logEntry.LogId, logEntry.LogText, logEntry.LogDate);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
            }
        }
    }
}
