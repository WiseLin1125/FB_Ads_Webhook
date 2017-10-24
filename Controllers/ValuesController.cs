using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Net;

namespace FB_Ads_Webhook.Controllers
{
    [Route("Authenticate/[controller]")]
    public class GetTokenController : Controller
    {
        // GET api/values
        [HttpGet]
        public string Get(string hub_challenge)
        {
            string returnValue = string.Empty;
            if (!string.IsNullOrEmpty(hub_challenge))
                returnValue = hub_challenge;
            return returnValue;
        }



        // GET api/values/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            Authentication auth = new Authentication
            {
                @object = "page",
                fields = "leadgen",
                verify_token = "1982944731975237|zfy5fBST0kAm6A43F07IMCXCgwc",
                callback_url = "http://localhost:5000/authenticate/gettoken"
            };

            using (WebClient wc = new WebClient())
            {
                string temp = JsonConvert.SerializeObject(auth);
                wc.Headers.Add("Content-Type", "application/json");
                var result = wc.UploadString("http://localhost:5000/authenticate/GetToken", "POST", JsonConvert.SerializeObject(auth));
            }

            return "value" + id;
        }

        // POST api/values
        [HttpPost]
        public string Post([FromBody]Authentication auth)
        {
            AuthenticationResponse response = new AuthenticationResponse();

            if (auth == null)
                response.success = false;
            return JsonConvert.SerializeObject(response);
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }
    }

    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        // GET api/values
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value" + id;
        }


        // POST api/values
        [HttpPost]
        public void Post([FromBody]string value)
        {
        }
    }



    public class Authentication
    {
        public string @object { get; set; }
        public string fields { get; set; }
        public string callback_url { get; set; }
        public string verify_token { get; set; }
    }

    public class AuthenticationResponse
    {
        public bool success = true;
    }
}
