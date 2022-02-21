using Android.App;
using Android.Content;
using Android.Media;
using Android.OS;
using Android.Widget;
using AndroidX.Core.App;
using System;

using System.Threading;
using Airlink.ViewModels;
using Airlink.Services;
using System.Threading.Tasks;

namespace Airlink.Droid
{
    [Service]
    public class BackgroundService : Service
    {
        static readonly int TimerWait = 150000;
        Timer timer;
        DateTime startTime;
        bool isStarted;


        static readonly int NOTIFICATION_ID = 1000;
        internal static readonly string COUNT_KEY = "count";
        private const string NOTIFICATION_CHANNEL_ID = "com.company.airlink.channel";
        public override void OnCreate()
        {
            StartOnForeground();
            base.OnCreate();
        }

        /*
         *This service will run until stopped explicitly because we are returning sticky
         *OnStartCommand method which executes once the phone boots-up
         */
        public void StartOnForeground()
        {
            Notification notification = new NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
                                          .SetContentTitle(Resources.GetString(Resource.String.app_name))
                                          .SetContentText(Resources.GetString(Resource.String.notification_text))
                                          .SetSmallIcon(Resource.Mipmap.icon)
                                          .SetOngoing(true)
                                          .Build();
            NotificationManager notificationManager = GetSystemService(Context.NotificationService) as NotificationManager;

            NotificationChannel chan = new NotificationChannel(NOTIFICATION_CHANNEL_ID, "On-going Notification", NotificationImportance.Min);

            notificationManager.CreateNotificationChannel(chan);

            StartForeground(NOTIFICATION_ID, notification);
        }
        public override StartCommandResult OnStartCommand(Intent intent, StartCommandFlags flags, int startId)
        {

            timer = new Timer(HandleTimerCallbackAsync, null, 0, TimerWait);

            if (isStarted)
            {
                PlaySound();
            }
            else
            {
                isStarted = true;
                PlaySound();
                timer = new Timer(HandleTimerCallbackAsync, startTime, 0, TimerWait);
            }

            Toast.MakeText(this, "Background service started", ToastLength.Long).Show();

            //This is allow permission to run service in Android with SDK more than 26.

            StartOnForeground();
            return StartCommandResult.NotSticky;
        }
        public override IBinder OnBind(Intent intent) => null;
        public async void HandleTimerCallbackAsync(object state)
        {
            BLEDevicesViewModel result = new BLEDevicesViewModel();
            await result.DoUpdates();
            //BLEDevicesViewModel.DoPosts();
            //PlaySound();
        }
        public void PlaySound()
        {
            try
            {
                var notification = RingtoneManager.GetDefaultUri(RingtoneType.Notification);

                Ringtone r = RingtoneManager.GetRingtone(Android.App.Application.Context, notification);

                r.Play();
            }
            catch (Exception ex)
            {
                throw ex;
            }

        }

        /* public override void OnDestroy()
         {
             PlaySound();

             timer.Dispose();
             timer = null;
             Toast.MakeText(this, "BLE Service is Destroyed.", ToastLength.Long).Show();
             base.OnDestroy();

         }*/
    }
}