using SQLite;
using System;
using System.Collections.Generic;
using System.Text;

namespace Airlink.Models.ProfileModel
{
    public class TenantKeyModel
    {
        [AutoIncrement, PrimaryKey]
        public int Id { get; set; }

        //Base End point
        public string BaseUrl { get; set; }

        //Tenant Token
        public string TenantToken { get; set; }
    }
}
