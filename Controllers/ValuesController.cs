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
        public string Get()
        {
            ///Authenticate/GetToken?hub.mode=subscribe&hub.challenge=1440531030&hub.verify_token=urAD_Subscription
            string result=string.Empty;
            string verify_token = HttpContext.Request.Query["hub.verify_token"].ToString() ?? string.Empty;
            string hub_challenge = HttpContext.Request.Query["hub.challenge"].ToString()??string.Empty;

            if (verify_token.Equals("urAD_Subscription") && !string.IsNullOrEmpty(hub_challenge))
                result = hub_challenge;
            
            return result;

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
                callback_url = "http://35.189.169.186/authenticate/gettoken"
            };

            ValueClass valueClass = new ValueClass
            {
                ad_id = "111",
                adgroup_id = "222",
                created_time = DateTime.Now.ToString(),
                leadgen_id = "333",
                page_id = "444",
                form_id = "555",
            };

            Leadgen leadgen = new Leadgen();
            leadgen.field="leadgen";
            leadgen.value = valueClass;

            List<Leadgen> leadgenList = new List<Leadgen>();
            leadgenList.Add(leadgen);

            Entry entry = new Entry
            {
                id="test",
                time= DateTime.Now.ToString(),
                changes=leadgenList
            };
            List<Entry> entryList = new List<Entry>();
            entryList.Add(entry);

            FacebookWebhook fw = new FacebookWebhook
            {
                @object="page",
                entry = entryList
            };

            using (WebClient wc = new WebClient())
            {
                string temp = JsonConvert.SerializeObject(fw);
                //wc.Headers.Add("Content-Type", "application/json");
                //var temp2 = "http://localhost:5000/api/values/1?para=" + JsonConvert.SerializeObject(fw);
                var result = wc.DownloadString("http://35.189.169.186/api/values?para=" + JsonConvert.SerializeObject(fw));
            }

            //using (WebClient wc = new WebClient())
            //{
            //    string temp = JsonConvert.SerializeObject(auth);
            //    wc.Headers.Add("Content-Type", "application/json");
            //    var result = wc.UploadString("http://35.189.169.186/api/values", "POST",
            //                                 JsonConvert.SerializeObject(fw));
            //}

            return "value" + id;
        }

        // POST 
        [HttpPost]
        public string Post([FromBody]FacebookWebhook auth)
        {
            AuthenticationResponse response = new AuthenticationResponse();

            if (auth != null)
            {
                using (WebClient wc = new WebClient())
                {
                    string temp = JsonConvert.SerializeObject(auth);
                    var result = wc.DownloadString("http://35.189.169.186/api/values/1?test"+JsonConvert.SerializeObject(auth));
                }
            }
            return JsonConvert.SerializeObject(response);
        }

    }

    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        // GET api/values
        [HttpGet]
        public IEnumerable<string> Get()
        {
            var test = HttpContext.Request.QueryString.Value;
            return new string[] { "value1", "value2" };
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public string Get(string id)
        {
            var test = HttpContext.Request.QueryString.Value;
            return id;
        }


        // POST api/values
        [HttpPost]
        public void Post([FromBody]FacebookWebhook fw)
        {
            var test = fw;

        }
    }

    public class FacebookWebhook
    {
        public string @object { get; set; }
        public List<Entry> entry { get; set; }
    }

    public class Entry{
        public string id { get; set; }
        public string time { get; set; }
        public List<Leadgen> changes { get; set; }
    }

    public class Leadgen
    {
        public string field { get; set; }
        public ValueClass @value { get; set; }
    }

    public class ValueClass
    {
        public string ad_id { get; set; }
        public string form_id { get; set; }
        public string leadgen_id { get; set; }
        public string created_time { get; set; }
        public string page_id { get; set; }
        public string adgroup_id { get; set; }
        public string email_hash { get; set; }
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
