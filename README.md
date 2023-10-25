# DelphiCacheControl
### Description
Delphi Cache Control is a cool feature that helps you save time in your applications. It allows you to store objects in memory and retrieve them quickly whenever you need them. Just imagine that you're creating objects with the same information over and over again. With Delphi Cache Control, you can avoid doing that repeatedly.

Moreover, it's super handy in API REST services. You can grab JSONs or Dataset data that you've requested in your API calls, and the next time, instead of fetching everything again, you simply pick up the item already stored in the cache.

The best part? Delphi Cache Control is "thread-safe," which means it works seamlessly in applications with multiple threads. Just include the main project unit and use the global variable "CacheControl."

And don't forget, you can add each object with a specific "Key." This makes it easy to retrieve the items you've stored in the cache. It's an easy and efficient way to keep things organized.

### How To use

```Delphi

uses uCacheControl.Impl;

var
MyClientDataSet: TClientDataSet;
begin
MyClientDataSet:= TClientDataSet.Create(Nil);

CacheControl.AddItem<TClientDataSet>('MyClientDataSet', MyClientDataSet);
```

Now, the variable MyClientDataSet can be accessed from anywhere in your source code that has the unit uCacheControl.Impl declared.

The component also features the Time to Live (TTL) functionality for an added object:

```Delphi

CacheControl.AddItem<TClientDataSet>('MyClientDataSet', MyClientDataSet, 5000);

```
Here I've set that MyClientDataSet will be stored for 5 seconds.

### Memory Leaks safe

Delphi Cache Control is also responsible for destroying the added items

### Samples

In the 'Samples' folder, there is a sample project that demonstrates usage, including a test involving multiple threads accessing the CacheControl."

### Delphi versions

Made and tested with Delphi 11.0, but will work from XE8 to 11.3.



<p align="center">
<img src="media/Delphi.png" alt="Delphi">
</p>
<h5 align="center">

Made with :heart: for Delphi
</h5>

