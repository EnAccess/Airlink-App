using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;

namespace Airlink
{
    public partial class MainPage : ContentPage
    {
        public MainPage()
        {
            InitializeComponent();
        }
        public interface IStatusBarStyleManager
        {
            void SetColoredStatusBar(string hexColor);
            void SetWhiteStatusBar();
        }


    }

}
