//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

[assembly: global::Xamarin.Forms.Xaml.XamlResourceIdAttribute("Airlink.Views.Profile.TenantKeyPage.xaml", "Views/Profile/TenantKeyPage.xaml", typeof(global::Airlink.Views.Profile.APIsPage))]

namespace Airlink.Views.Profile {
    
    
    [global::Xamarin.Forms.Xaml.XamlFilePathAttribute("Views\\Profile\\TenantKeyPage.xaml")]
    public partial class APIsPage : global::Xamarin.Forms.ContentPage {
        
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Xamarin.Forms.Build.Tasks.XamlG", "2.0.0.0")]
        private global::Airlink.PclCustomUI.CustomEntry urlEntry;
        
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Xamarin.Forms.Build.Tasks.XamlG", "2.0.0.0")]
        private global::Airlink.PclCustomUI.CustomEntry tokenEntry;
        
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Xamarin.Forms.Build.Tasks.XamlG", "2.0.0.0")]
        private global::Xamarin.Forms.Button SaveCommand;
        
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Xamarin.Forms.Build.Tasks.XamlG", "2.0.0.0")]
        private void InitializeComponent() {
            global::Xamarin.Forms.Xaml.Extensions.LoadFromXaml(this, typeof(APIsPage));
            urlEntry = global::Xamarin.Forms.NameScopeExtensions.FindByName<global::Airlink.PclCustomUI.CustomEntry>(this, "urlEntry");
            tokenEntry = global::Xamarin.Forms.NameScopeExtensions.FindByName<global::Airlink.PclCustomUI.CustomEntry>(this, "tokenEntry");
            SaveCommand = global::Xamarin.Forms.NameScopeExtensions.FindByName<global::Xamarin.Forms.Button>(this, "SaveCommand");
        }
    }
}
