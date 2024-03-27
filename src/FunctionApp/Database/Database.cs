using Microsoft.EntityFrameworkCore;

namespace FunctionApp.Database;

public class Database : DbContext
{
    public Database(DbContextOptions options) : base(options)
    {
    }

    public DbSet<LogTable> Log { get; set; }
}