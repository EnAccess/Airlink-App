using Airlink.Models;
using Airlink.Models.JWTLoginSpace;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Airlink.Services
{
    public class UserLoginRequest
    {
        public async static Task<JWTResponse> LoginRequest(string airlinkURL, string username, string password)
        {
            JWTResponse jwtResponse;
            HttpClient client = new HttpClient();

            string contents = "{\"username\": \"" + username + "\", \"password\": \"" + password + "\"}";
            StringContent content = new StringContent(contents, Encoding.UTF8, "application/json");

            string url = airlinkURL + "/api/auth/login";

            var response = await client.PostAsync(url, content);

            if (response.IsSuccessStatusCode)
            {
                jwtResponse.token = JWTLoginResponse.FromJson(await response.Content.ReadAsStringAsync()).Token;
                jwtResponse.refreshToken = JWTLoginResponse.FromJson(await response.Content.ReadAsStringAsync()).RefreshToken;
                return jwtResponse;
            }
            else
            {
                jwtResponse.token = null;
                jwtResponse.refreshToken = null;
                return jwtResponse;
            }

        }
    }
}
