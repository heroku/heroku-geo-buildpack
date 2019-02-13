Heroku Buildpack: Geo
=====================

Heroku Buildpack Geo is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) that
installs the Geo/GIS libraries [GDAL](https://www.gdal.org/), [GEOS](https://trac.osgeo.org/geos/) and [PROJ](https://proj4.org/)

This is useful for using [GeoDjango](https://docs.djangoproject.com/en/2.1/ref/contrib/gis/) or [RGeo](https://github.com/rgeo/rgeo) on Heroku

Usage
-----

This buildpack is designed to be used in combination with other buildpacks by using Heroku's [multiple buildpack support](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app).

Ensure that Heroku Buildpack Geo is the first buildpack on your list of buildpacks:


```
$ heroku buildpacks
=== Buildpack URLs
1. https://github.com/KevinBrolly/heroku-geo-buildpack.git
2. heroku/python
```

Default Versions
----------------

The buildpack will install the following version by default:

GDAL - 2.4.0
GEOS - 3.7.1
PROJ - 5.2.0

You can change the version of each library that will be installed by setting the `GDAL_VERSION`, `GEOS_VERSION` or `PROJ_VERSION` config variables.
