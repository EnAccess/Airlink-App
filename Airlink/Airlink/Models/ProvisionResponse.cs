﻿using System;
namespace Airlink.Models
{// <auto-generated />
 //
 // To parse this JSON data, add NuGet 'Newtonsoft.Json' then do:
 //
 //    using ProvisionResponse;
 //
 //    var provisionResponse = ProvisionResponse.FromJson(jsonString);

    namespace ProvisionSpace
    {
        using System;
        using System.Collections.Generic;

        using System.Globalization;
        using Newtonsoft.Json;
        using Newtonsoft.Json.Converters;

        public partial class ProvisionResponse
        {
            [JsonProperty("status")]
            public string Status { get; set; }

            [JsonProperty("credentialsType")]
            public string CredentialsType { get; set; }

            [JsonProperty("accessToken")]
            public string AccessToken { get; set; }
        }

        public partial class ProvisionResponse
        {
            public static ProvisionResponse FromJson(string json) => JsonConvert.DeserializeObject<ProvisionResponse>(json, ProvisionSpace.Converter.Settings);
        }

        public static class Serialize
        {
            public static string ToJson(this ProvisionResponse self) => JsonConvert.SerializeObject(self, ProvisionSpace.Converter.Settings);
        }

        internal static class Converter
        {
            public static readonly JsonSerializerSettings Settings = new JsonSerializerSettings
            {
                MetadataPropertyHandling = MetadataPropertyHandling.Ignore,
                DateParseHandling = DateParseHandling.None,
                Converters =
            {
                new IsoDateTimeConverter { DateTimeStyles = DateTimeStyles.AssumeUniversal }
            },
            };
        }
    }
}