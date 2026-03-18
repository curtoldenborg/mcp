/*

    datex.cls - extended date class - all static

    v18.02.1393 / 18-oct-16 / TLAR

*/

class DateX:

    {include/xreftype.i}

    def static buffer crossref for crossref.

    def public static property month as char extent 12 initial [
        "Januar":T7,
        "Februar":T8,
        "Mars":T5,
        "April":T,
        "Mai":T,
        "Juni":T,
        "Juli":T,
        "August":T,
        "September":T,
        "Oktober":T,
        "November":T,
        "Desember":T
    ] get.

    def public static property rfc2616-month as char extent 12 initial [
        "Jan":U,
        "Feb":U,
        "Mar":U,
        "Apr":U,
        "May":U,
        "Jun":U,
        "Jul":U,
        "Aug":U,
        "Sep":U,
        "Oct":U,
        "Nov":U,
        "Dec":U
    ] get.

    def public static property weekday as char extent 7 initial [
        "Søndag":T,
        "Mandag":T,
        "Tirsdag":T,
        "Onsdag":T9,
        "Torsdag":T8,
        "Fredag":T,
        "Lørdag":T8
    ] get.

    def public static property dummy-date as date initial 01/01/1950 get.

    method public static int GetMonth (s as char):

        def var i as int initial 1 no-undo.

        do i = 1 to 12 while not s = DateX:month[i]: end.

        return(if i <= 12 then i else ?).

    end.

    method public static int GetMonthrfc2616 (s as char):

        def var i as int initial 1 no-undo.

        do i = 1 to 12 while not s = DateX:rfc2616-month[i]: end.

        return(if i <= 12 then i else ?).

    end.


    method public static char DateToString (dt as date):
        return(if dt = ?
                then '?':U
                 else string(year(dt), "9999":U) +
                       string(month(dt), "99":U) +
                        string(day(dt), "99":U)).
    end method.

    method public static char DateToISOString (dt as date):
        return(if dt = ?
                then '':U
                 else iso-date(dt)).
    end method.

    method public static date StringToDate (dt as char):

        def var d as date no-undo.

        d = if dt = ? or length(dt) < 8
             then ?
              else date(integer(substring(dt, 5, 2)),
                         integer(substring(dt, 7, 2)),
                          integer(substring(dt, 1, 4))) no-error.

        return(if error-status:error then ? else d).

    end method.

    method public static date ISOStringToDate (dt as char):

        def var d as date no-undo.

        assign
            dt = if num-entries(dt, "T":U) = 2 then entry(1, dt, "T":U) else dt.
            d  = if num-entries(dt, "-":U) = 3
                  then date(integer(entry(2, dt, "-":U)),
                             integer(entry(3, dt, "-":U)),
                              integer(entry(1, dt, "-":U)))
                   else ? no-error.

        return(if error-status:error then ? else d).

    end method.
    
    // Thu, 03 Dec 2020 11:35:44 GMT 
    method public static datetime ISOStringToDateRfc(dt as char):
        def var month as integer no-undo. 
        def var dtime as datetime no-undo.
        def var ttime as char no-undo. 
        def var d as date no-undo.
        
        dt =  left-trim(trim(entry(2, dt,",":U))).
        month = GetMonthrfc2616(entry(2, dt," ":U)).
        ttime =  entry(4, dt," ").
        
        dtime = datetime-tz(month,int(entry(1, dt," ")),int(entry(3, dt," ")),
              integer(entry(1,ttime,":")),
              integer(entry(2,ttime,":")),
              integer(entry(3,ttime,":")),
              if entry(5, dt," ") = "GMT" THEN 0 ELSE integer(entry(5, dt," "))) no-error.
        
        return(if error-status:error then ? else dtime).

    end method.
        
    

    method public static int ISOStringToTime (dt as char):

        dt = if num-entries(dt, "T":U) = 2 then entry(2, dt, "T":U) else ?.

        return(if num-entries(dt, ":":U) > 1
                then integer(entry(1, dt, ":":U)) * 3600 +
                      integer(entry(2, dt, ":":U)) * 60 +
                       if num-entries(dt, ":":U) > 2 then integer(entry(3, dt, ":":U)) else 0
                 else ?).

    end method.

    method public static char DateToYYYYMM (dt as date):
        return(if dt = ?
                then '?':U
                 else string(year(dt), "9999":U) +
                       string(month(dt), "99":U)).
    end method.

    method public static date Min (d1 as date, d2 as date):
        return(if d1 <> ? and d2 <> ? then minimum(d1, d2) else if d1 <> ? then d1 else d2).
    end method.

    method public static date Max (d1 as date, d2 as date):
        return(if d1 <> ? and d2 <> ? then maximum(d1, d2) else if d1 <> ? then d1 else d2).
    end method.

    method public static int DateToWeekday (d as date):
        return(((weekday(d) + 5) mod 7) + 1).
    end method.

    method public static int Weeks (yr as int):

        yr = (yr - 1917) mod 28 + 1917.

        return(if yr = 1936 or
                   yr = 1920 or
                    (yr <> 1920 and DateToWeekday(date(1, 1, yr)) = 4)
                then 53
                 else 52).

    end method.

    method public static date WeekOneStart (yr as int):

        def var i as int no-undo.
        def var week1date as date initial 01/01/1917 no-undo.
        def var baseyr as int no-undo.

        baseyr = (yr - 1917) mod 28 + 1917.

        do i = 1917 to baseyr - 1:
            week1date = week1date + 7 * Weeks(i).
        end.

        return(date(month(week1date), day(week1date), yr - if month(week1date) = 12
                                                            then 1
                                                             else 0)).

    end method.

    /**********************************************
     *                                            *
     * DATE_DateToWeek                            *
     * weeknumber of a given date         *
     *                                            *
     **********************************************/

    method public static int DateToWeek (dt as date):

        def var ty as logical no-undo.
        def var week as int no-undo.

        assign
            ty   = dt >= WeekOneStart(year(dt))
            week = if ty
                    then integer(truncate((dt - WeekOneStart(year(dt))) / 7, 0) + 1)
                     else Weeks(year(dt) - 1).

        return(if ty and week > 52 and week > Weeks(year(dt)) then 1 else week).

    end method.

    /**********************************************
     *                                            *
     * DATE_WeekToDate                            *
     * startdate of a given week and year *
     *                                            *
     **********************************************/

    method public static date WeekStartDate (yr as int, week as int):
        return(if week = 53 and Weeks(yr) = 53
                then WeekOneStart(yr + 1) - 7
                 else WeekOneStart(yr) + 7 * (week - 1)).
    end method.

    method public static date YearWeekStartDate (yrwk as int):

        return(WeekStartDate(integer(truncate(yrwk / 100, 0)), integer(yrwk - truncate(yrwk / 100, 0) * 100))).

    end method.

    method public static int ToYearWeek (d as date):
        return((year(d) + if d < WeekOneStart(year(d))
                           then -1
                            else if d >= WeekOneStart(year(d) + 1)
                                  then 1
                                   else 0) * 100 + DateToWeek(d)).
    end method.

    method public static logical IsHoliday (d as date):
        return(weekday(d) = 1 or
                can-find(first crossref where
                                 crossref.type    = {&xcfg_holiday} and
                                 crossref.rel_id1 = 99990000 +
                                                     month(d) * 100 +
                                                      day(d)) or
                 can-find(first crossref where
                                  crossref.type    = {&xcfg_holiday} and
                                  crossref.rel_id1 = year(d) * 10000 +
                                                      month(d) * 100 +
                                                       day(d))).
    end method.

    method public static char GetHolidayName (d as date):

        def var s as char initial ? no-undo.

        for first crossref where
                    crossref.type    = {&xcfg_holiday} and
                    crossref.rel_id1 = year(d) * 10000 + month(d) * 100 + day(d) no-lock:

            s = crossref.txt.

        end.

        if s = ? then
            for first crossref where
                        crossref.type    = {&xcfg_holiday} and
                        crossref.rel_id1 = 99990000 + month(d) * 100 + day(d) no-lock:

            s = crossref.txt.

        end.

        return(s).

    end method.

    method public static logical IsWorkday (d as date):

        return(weekday(d) <> 7 and not IsHoliday(d)).

    end method.

    method public static void GetLastWeek (output date_from as date, output date_to as date):

        assign
            date_to   = YearWeekStartDate(ToYearWeek(today)) - 1
            date_from = date_to - 6.

    end method.

    method public static void GetLastMonth (output date_from as date, output date_to as date):

        assign
            date_to   = date(month(today), 1, year(today)) - 1
            date_from = date(month(date_to), 1, year(date_to)).

    end method.

    method public static void GetThisMonth (output date_from as date, output date_to as date):

        assign
            date_from = date(month(today), 1, year(today))
            date_to   = date_from + 32
            date_to   = date(month(date_to), 1, year(date_to)) - 1.

    end method.

    method public static void GetLastMonths (months as int, output date_from as date, output date_to as date):

        GetLastMonth(output date_from, output date_to).

        do while months > 1:
            assign
                date_from  = date(month(date_from - 1), 1, year(date_from - 1))
                months     = months - 1.
        end.

    end method.

    method public static void GetYearToDate (output date_from as date, output date_to as date):

        assign
            date_to   = today
            date_from = date(1, 1, year(date_to)).

    end method.

    method public static void GetYearsToDate (years as int, output date_from as date, output date_to as date):

        assign
            date_to   = today
            date_from = date(1, 1, year(date_to) - years).

    end method.

end class.