using Airlink.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Airlink.Services
{

    /*
     * This Class used in accessing all scanned Bluetooth Low Energy devices temporary
     * It adds scanned devices by UUID
     * Retrieves Scanned devices
     * Retrieves devices on Refresh
     * updates the scanned device by UUID
     * deletes the scanned device by UUID
     * Deletes all Scanned devices
     */
    public class MockDataStore : IDataStore<BleItem>
    {

        readonly List<BleItem> items;

        public MockDataStore()
        {
            items = new List<BleItem>()
            {
            };
        }
        /*
         * Add Item
         */
        public async Task<bool> AddItemAsync(BleItem item)
        {
            items.Add(item);

            return await Task.FromResult(true);
        }
        /*
        * Update Item
        */
        public async Task<bool> UpdateItemAsync(BleItem item)
        {
            var oldItem = items.Where((BleItem arg) => arg.Id == item.Id).FirstOrDefault();
            items.Remove(oldItem);
            items.Add(item);

            return await Task.FromResult(true);
        }
        /*
        * Delete Item
        */
        public async Task<bool> DeleteItemAsync(string id)
        {
            var oldItem = items.Where((BleItem arg) => arg.Id == id).FirstOrDefault();
            items.Remove(oldItem);

            return await Task.FromResult(true);
        }
        /*
        * Get Item
        */
        public async Task<BleItem> GetItemAsync(string id)
        {
            return await Task.FromResult(items.FirstOrDefault(s => s.Id == id));
        }
        /*
       * Get Item with refresh
       */
        public async Task<IEnumerable<BleItem>> GetItemsAsync(bool forceRefresh = false)
        {
            return await Task.FromResult(items);
        }
    }


    /*
     * This Class used in accessing Property of a connected Bluetooth Low Energy devices temporary
     * It adds selected property by UUID
     * Retrieves all details of connected property
     * Retrieves details of connected property on Refresh
     * updates details of connected property by UUID
     * deletes details of connected property by UUID
     * Deletes a property
     */
    public class MockAllPropertyDataStore : IPropertyDataStore<Property>
    {

        readonly List<Property> items;

        public MockAllPropertyDataStore()
        {
            items = new List<Property>()
            {
            };
        }
        /*
         * Add Item
         */
        public async Task<bool> AddItemAsync(Property item)
        {
            items.Add(item);

            return await Task.FromResult(true);
        }
        /*
        * Update Item
        */
        public async Task<bool> UpdateItemAsync(Property item)
        {
            var oldItem = items.Where((Property arg) => arg.Id == item.Id).FirstOrDefault();
            items.Remove(oldItem);
            items.Add(item);

            return await Task.FromResult(true);
        }
        /*
        * Delete Item
        */
        public async Task<bool> DeleteItemAsync(string id)
        {
            var oldItem = items.Where((Property arg) => arg.Id == id).FirstOrDefault();
            items.Remove(oldItem);

            return await Task.FromResult(true);
        }
      /*
      * Delete All Items
      */
        public async Task<bool> DeleteItemsAsync()
        {
            items.Clear();

            return await Task.FromResult(true);
        }
        /*
        * Get Item
        */
        public async Task<Property> GetItemAsync(string id)
        {
            return await Task.FromResult(items.FirstOrDefault(s => s.Id == id));
        }
        /*
       * Get Item with refresh
       */
        public async Task<IEnumerable<Property>> GetItemsAsync(bool forceRefresh = false)
        {
            return await Task.FromResult(items);
        }
    }

    /*
     * This Class used in accessing only Property UUID of a connected Bluetooth Low Energy devices temporary
     * It adds selected propertyUUID
     * Retrieves all details of connected property
     * Retrieves details of connected property on Refresh
     * updates details of connected property 
     * deletes details of connected property 
     * Deletes a property
     */
    public class MockPropertyDataStore : IPropertyStore<PropertyID>
    {

        readonly List<PropertyID> items;

        public MockPropertyDataStore()
        {
            items = new List<PropertyID>()
            {
            };
        }
        /*
         * Add Item
         */
        public async Task<bool> AddItemAsync(PropertyID item)
        {
            items.Add(item);

            return await Task.FromResult(true);
        }
        /*
        * Delete Item
        */
        public async Task<bool> DeleteItemAsync(string id)
        {
            var oldItem = items.Where((PropertyID arg) => arg.PropertyUUID == id).FirstOrDefault();
            items.Remove(oldItem);

            return await Task.FromResult(true);
        }
     /*
     * Delete All Items
     */
        public async Task<bool> DeleteItemsAsync()
        {
            items.Clear();

            return await Task.FromResult(true);
        }
        /*
        * Get Item
        */
        public async Task<PropertyID> GetItemAsync()
        {
            
            return await Task.FromResult(items.SingleOrDefault());
        }
        /*
       * Get Item with refresh
       */
        public async Task<IEnumerable<PropertyID>> GetItemsAsync(bool forceRefresh = false)
        {
            return await Task.FromResult(items);
        }
    }
}
