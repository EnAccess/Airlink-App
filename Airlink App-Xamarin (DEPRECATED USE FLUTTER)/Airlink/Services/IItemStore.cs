using System;
using System.Collections.Generic;
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
    public interface IItemStore<T>
    {
        Task<bool> AddItemAsync(T item);
        Task<bool> UpdateItemAsync(T item);
        Task<bool> DeleteItemAsync(string id);
        Task<T> GetItemAsync(string id);
        Task<IEnumerable<T>> GetItemsAsync(bool forceRefresh = false);
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
    public interface IPropertyDataStore<T>
    {
        Task<bool> AddItemAsync(T item);
        Task<bool> UpdateItemAsync(T item);
        Task<bool> DeleteItemAsync(string id);
        Task<bool> DeleteItemsAsync();
        Task<T> GetItemAsync(string id);
        Task<IEnumerable<T>> GetItemsAsync(bool forceRefresh = false);
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
    public interface IPropertyStore<T>
    {
        Task<bool> AddItemAsync(T item);
        Task<bool> DeleteItemsAsync();
        Task<T> GetItemAsync();
        Task<IEnumerable<T>> GetItemsAsync(bool forceRefresh = false);
    }
}
