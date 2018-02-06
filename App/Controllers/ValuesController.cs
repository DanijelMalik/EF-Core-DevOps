using System.Collections.Generic;
using System.Threading.Tasks;
using EfCore.DevOps.Domain;
using EfCore.DevOps.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EfCore.DevOps.App.Controllers
{
    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        private AppDbContext Context { get; }

        public ValuesController(AppDbContext context)
        {
            Context = context;
        }

        [HttpGet]
        [Produces(typeof(IEnumerable<Value>))]
        public async Task<IActionResult> Get()
        {
            return Ok(await Context.Values.ToListAsync());
        }

        [HttpGet("{id}")]
        [Produces(typeof(Value))]
        public async Task<IActionResult> GetById(int id)
        {
            var entity = await Context.Values.FindAsync(id);

            if (entity == null)
            {
                return NotFound();
            }

            return Ok(entity);
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody]string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return BadRequest();
            }

            var entity = new Value { Name = value };
            await Context.Values.AddAsync(entity);
            await Context.SaveChangesAsync();

            return CreatedAtAction("GetById", new { id = entity.Id });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Put(int id, [FromBody]string value)
        {
            var entity = await Context.Values.FindAsync(id);

            if (entity == null)
            {
                return NotFound();
            }

            entity.Name = value;
            await Context.SaveChangesAsync();

            return Accepted();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await Context.Values.FindAsync(id);

            if (entity == null)
            {
                return NotFound();
            }

            Context.Values.Remove(entity);
            await Context.SaveChangesAsync();

            return NoContent();
        }
    }
}
