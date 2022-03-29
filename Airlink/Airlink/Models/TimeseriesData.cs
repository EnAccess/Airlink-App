using SQLite;
using System;
using System.Collections.Generic;
using System.Text;
using Xamarin.Forms.Xaml;

namespace Airlink.Models.PUEAdvert
{
    [XamlCompilation(XamlCompilationOptions.Compile)]

    public class TimeseriesData
    {

        //Device ID
        [PrimaryKey]
        [AutoIncrement]
        [NotNull]
        public int Id { get; set; }
        //Device ID
        public string Did { get; set; }

        //Timeseries json data
        public string Json { get; set; }

    }
}
