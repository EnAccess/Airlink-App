using System;
namespace Airlink
{
    public class OldCodeRepo
    {
        public OldCodeRepo()
        {
        }
    }
}
from ProfilePage.xaml line 10
            < StackLayout Grid.Row = "0" Margin = "0,-100,0,0" >
   
                   < Grid RowDefinitions = "Auto,*" >
    

                        < Path
                        Grid.RowSpan = "1"
                        Grid.ColumnSpan = "1"
                        HorizontalOptions = "FillAndExpand"
                        VerticalOptions = "FillAndExpand"
                        Fill = "{AppThemeBinding Dark=#1B75BA, Light=#1B75BA}"
                        Data = "M0,0H720V217.216s-184.713,64.169-347.376,64.169S0,217.216,0,217.216V0"
                        Aspect = "Uniform" Scale = "1.01" />
  
                      < !--Start of the User credential section-->
                    <StackLayout  Grid.Row="1" Margin="10,-120,10,0">
                        <pkv:PancakeView BackgroundColor = "{StaticResource Background}" CornerRadius="10,0,0,10" HorizontalOptions="FillAndExpand"
                                        Shadow="{pkv:ShadowMarkup Color={StaticResource Primary}, Offset='10,10'}">
                            <Grid ColumnDefinitions="Auto,*,Auto" Margin="10">
                                <pkv:PancakeView BackgroundColor = "{StaticResource Background}" CornerRadius="20,0,0,20"  Grid.Column="0"
                                                 Shadow="{pkv:ShadowMarkup Color={StaticResource Secondary},Offset='10,10'}"  HeightRequest="40" WidthRequest="50">
                                    <Image Source="profil.png" Aspect="Fill"/>
                                </pkv:PancakeView >
                                < StackLayout Grid.Column = "1" >
 
                                     < Grid RowDefinitions = "Auto,Auto" >
  
                                          < Label Text = "Customer Name" Padding = "0,10,0,5" TextColor = "{StaticResource Black}" HorizontalOptions = "CenterAndExpand" VerticalOptions = "Center"
                                               Scale = "1" />
                                        < Label Text = "+255 714 000 609" TextColor = "{StaticResource Color_1}" HorizontalOptions = "CenterAndExpand"
                                               VerticalOptions = "CenterAndExpand" Grid.Row = "1" />
  
                                      </ Grid >
  
                                  </ StackLayout >
  
                                  < ImageButton Source = "foward.png" HeightRequest = "40" WidthRequest = "40" Grid.Column = "2" Command = "{Binding ProfileCommand}" CommandParameter = "12393"
                                             BackgroundColor = "{StaticResource Background}" />
                            </ Grid >
                        </ pkv:PancakeView >
 
                     </ StackLayout >
 
                     < !--End of the User credential section>
                </Grid-->
            </StackLayout>
    line 16
                               <!--Start of the device section-->
                            <StackLayout Grid.Row="0" Margin="20,0">
                                <Grid ColumnDefinitions="Auto,Auto">
                                    <BoxView Color="{StaticResource Background}"
                                     CornerRadius="10" Grid.Column="0"
                                     WidthRequest="40"
                                     HeightRequest="40"
                                     VerticalOptions="Center"
                                     HorizontalOptions="Center" />
                                    <Button Text="Devices" Grid.Column="1"  Margin="20,0" HorizontalOptions="CenterAndExpand" VerticalOptions="CenterAndExpand"
                                       FontSize="Title" BackgroundColor="{StaticResource Color_2}" TextColor="{StaticResource Black}"
                                            Command="{Binding DevicesCommand}"/>
                                </Grid>
                            </StackLayout>
                            <!--End of the device section-->
     line 45
                                <!--Start of the Logout section-->
                            <StackLayout Grid.Row="3" Margin="20,0">
                                <Grid ColumnDefinitions="Auto,Auto">
                                    <BoxView Color="{StaticResource Background}"
                                     CornerRadius="10" Grid.Column="0"
                                     WidthRequest="40"
                                     HeightRequest="40"
                                     VerticalOptions="Center"
                                     HorizontalOptions="Center" />
                                    <Button Text="Logout" Grid.Column="1"  Margin="20,0" HorizontalOptions="CenterAndExpand" VerticalOptions="CenterAndExpand"
                                       FontSize="Title" BackgroundColor="{StaticResource Color_2}" TextColor="{StaticResource Black}"
                                            Command="{Binding LogoutCommand}"/>
                                </Grid>
                            </StackLayout>
                            <!--End of the Logout section-->
