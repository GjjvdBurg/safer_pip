(Slightly) Safer pip
====================

This bash script creates a slightly safer way to install Python packages with 
`pip <https://github.com/pypa/pip>`_. It was inspired by `this blog post 
<http://incolumitas.com/2016/06/08/typosquatting-package-managers/>`_ by 
`NikolaiT <https://github.com/NikolaiT>`_, and by `Yaourt 
<https://github.com/archlinuxfr/yaourt>`_.

What this script does is download the desired package with pip, unzips it, 
asks the user to verify the ``setup.py`` file, and installs it when the user 
confirms to do so. It's very basic and doesn't provide strong security, but it 
at least allows the user to easily verify the ``setup.py`` file before 
installing a package.

Note that this script installs packages to the users directory by default by 
using the ``--user`` flag to ``pip install``. This way, it shouldn't be 
necessary to run pip with administrator privileges.
