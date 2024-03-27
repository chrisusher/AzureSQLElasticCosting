using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FunctionApp.Database
{
    public class LogTable
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Key]
        public int LogId { get; set; }

        public string LogText { get; set; }

        public DateTime LogDate { get; set; } = DateTime.UtcNow;
    }
}