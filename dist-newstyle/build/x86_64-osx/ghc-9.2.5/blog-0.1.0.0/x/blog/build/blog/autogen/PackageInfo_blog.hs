{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module PackageInfo_blog (
    name,
    version,
    synopsis,
    copyright,
    homepage,
  ) where

import Data.Version (Version(..))
import Prelude

name :: String
name = "blog"
version :: Version
version = Version [0,1,0,0] []

synopsis :: String
synopsis = "Hakyll project template from stack"
copyright :: String
copyright = "2016 Author name here"
homepage :: String
homepage = "https://github.com/githubuser/blog#readme"
