using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace Airlink.Models
{
    /*
 * OCF Recource Model

 */
    public class Resource
    {
        public const string nxresguid = "dea53145-5580-46f8-b1a6-a1fd0072912a"; //FIXME move to global constants? Make updateable? This is a nx.res locator
        public string Name { get; set; }

        public string Id { get; set; }
        public ObservableCollection<Property> PropertiesList { get; set; }
    }
}
