using EfCore.DevOps.Domain;
using Microsoft.EntityFrameworkCore;

namespace EfCore.DevOps.Persistence
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {

        }
        public DbSet<Value> Values { get; set; }
    }
}