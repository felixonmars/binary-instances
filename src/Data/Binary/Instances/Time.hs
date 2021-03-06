{-# OPTIONS_GHC -fno-warn-orphans #-}
module Data.Binary.Instances.Time where

import Control.Monad       (liftM2, liftM3)
import Data.Binary         (Binary, Get, Put, get, put)
import Data.Binary.Orphans ()
import Data.Word           (Word8)

import qualified Data.Fixed                    as Fixed
import qualified Data.Time.Calendar.Compat     as Time
import qualified Data.Time.Clock.Compat        as Time
import qualified Data.Time.Clock.System.Compat as Time
import qualified Data.Time.Clock.TAI.Compat    as Time
import qualified Data.Time.LocalTime.Compat    as Time

instance Binary Time.Day where
  get = fmap Time.ModifiedJulianDay get
  put = put . Time.toModifiedJulianDay

instance Binary Time.UniversalTime where
  get = fmap Time.ModJulianDate get
  put = put . Time.getModJulianDate

instance Binary Time.DiffTime where
  get = fmap Time.picosecondsToDiffTime get
  put = (put :: Fixed.Pico -> Put)  . realToFrac

instance Binary Time.UTCTime where
  get = liftM2 Time.UTCTime get get
  put (Time.UTCTime d dt) = put d >> put dt

instance Binary Time.NominalDiffTime where
  get = fmap realToFrac (get :: Get Fixed.Pico)
  put = (put :: Fixed.Pico -> Put)  . realToFrac

instance Binary Time.TimeZone where
  get = liftM3 Time.TimeZone get get get
  put (Time.TimeZone m s n) = put m >> put s >> put n

instance Binary Time.TimeOfDay where
  get = liftM3 Time.TimeOfDay get get get
  put (Time.TimeOfDay h m s) = put h >> put m >> put s

instance Binary Time.LocalTime where
  get = liftM2 Time.LocalTime get get
  put (Time.LocalTime d tod) = put d >> put tod

instance Binary Time.ZonedTime where
  get = liftM2 Time.ZonedTime get get
  put (Time.ZonedTime t z) = put t >> put z

instance Binary Time.AbsoluteTime where
  get = fmap (flip Time.addAbsoluteTime Time.taiEpoch) get
  put = put . flip Time.diffAbsoluteTime Time.taiEpoch

instance Binary Time.SystemTime where
    get = liftM2 Time.MkSystemTime get get
    put (Time.MkSystemTime s ns) = put s >> put ns

instance Binary Time.CalendarDiffDays where
    get = liftM2 Time.CalendarDiffDays get get
    put (Time.CalendarDiffDays m d) = put m >> put d

instance Binary Time.CalendarDiffTime where
    get = liftM2 Time.CalendarDiffTime get get
    put (Time.CalendarDiffTime m nt) = put m >> put nt

instance Binary Time.DayOfWeek where
    put Time.Sunday    = put (0 :: Word8)
    put Time.Monday    = put (1 :: Word8)
    put Time.Tuesday   = put (2 :: Word8)
    put Time.Wednesday = put (3 :: Word8)
    put Time.Thursday  = put (4 :: Word8)
    put Time.Friday    = put (5 :: Word8)
    put Time.Saturday  = put (6 :: Word8)

    get = do
        i <- get
        return $ case mod (i :: Word8) 7 of
            0 -> Time.Sunday
            1 -> Time.Monday
            2 -> Time.Tuesday
            3 -> Time.Wednesday
            4 -> Time.Thursday
            5 -> Time.Friday
            6 -> Time.Saturday
            _ -> error "panic: get @DayOfWeek"
