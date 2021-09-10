using Airlink.Services;
using PeterO.Cbor;
using System;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;



namespace Airlink.Views
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class CBORPage : ContentPage
    {
        public CBORPage()
        {
            InitializeComponent();
        }

        private void Button_Clicked(object sender, EventArgs e)
        {

            // The following creates a CBOR map and adds
            // several kinds of objects to it
            var cbor = CBORObject.NewMap()
               .Add("item", "any string")
               .Add("number", 42)
               .Add("map", CBORObject.NewMap().Add("number", 42))
               .Add("array", CBORObject.NewArray().Add(999f).Add("xyz"))
               .Add("bytes", new byte[] { 0, 1, 2 });
            // The following converts the map to CBOR
            byte[] bytes = cbor.EncodeToBytes();
            var jcbor = DataConverter.BytesToHexString(bytes);
            // The following converts the map to JSON
            //string json = cbor.ToString();
            var json = CBORObject.DecodeFromBytes(bytes);
            Console.WriteLine(json);
                cbort.Text = json.ToString();

        }
    }
}