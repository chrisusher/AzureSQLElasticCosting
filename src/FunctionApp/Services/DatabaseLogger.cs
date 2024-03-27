using FunctionApp.Database;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.SqlServer;
using Microsoft.Extensions.Configuration;
using LogDb = FunctionApp.Database.Database;

namespace FunctionApp.Services
{
    public class DatabaseLogger
    {
        private readonly LogDb _dbContext;

        public DatabaseLogger(
            IConfigurationRoot configuration,
            int databaseNumber)
        {
            var connectionStringBuilder = new SqlConnectionStringBuilder
            {
                InitialCatalog = $"elasticdb-{databaseNumber}",
                DataSource = configuration["DB_SERVER"],
                UserID = "adminuser",
                Password = configuration["DB_PASSWORD"]
            };

            var dbOptions = new DbContextOptionsBuilder<LogDb>();
            dbOptions.UseSqlServer(connectionStringBuilder.ConnectionString);

            _dbContext = new LogDb(dbOptions.Options); 
        }

        public async Task<LogTable> GetLastLogAsync()
        {
            return await _dbContext.Log.LastOrDefaultAsync();
        }

        public async Task<LogTable> LogAsync(string message)
        {
            var logTable = new LogTable
            {
                LogText = message
            };

            await _dbContext.Log.AddAsync(logTable);
            await _dbContext.SaveChangesAsync();

            return logTable;
        }
    }
}