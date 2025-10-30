#!/bin/sh

# @requires: jq(1)

# Seconds until script output cache is stale
INTERVAL=$(( 60 * 15 ))

state2abbrev () {
    case "$1" in
        "Alabama"                  ) echo "AL";;
        "Kentucky"                 ) echo "KY";;
        "Ohio"                     ) echo "OH";;
        "Alaska"                   ) echo "AK";;
        "Louisiana"                ) echo "LA";;
        "Oklahoma"                 ) echo "OK";;
        "Arizona"                  ) echo "AZ";;
        "Maine"                    ) echo "ME";;
        "Oregon"                   ) echo "OR";;
        "Arkansas"                 ) echo "AR";;
        "Maryland"                 ) echo "MD";;
        "Pennsylvania"             ) echo "PA";;
        "American Samoa"           ) echo "AS";;
        "Massachusetts"            ) echo "MA";;
        "Puerto Rico"              ) echo "PR";;
        "California"               ) echo "CA";;
        "Michigan"                 ) echo "MI";;
        "Rhode Island"             ) echo "RI";;
        "Colorado"                 ) echo "CO";;
        "Minnesota"                ) echo "MN";;
        "South Carolina"           ) echo "SC";;
        "Connecticut"              ) echo "CT";;
        "Mississippi"              ) echo "MS";;
        "South Dakota"             ) echo "SD";;
        "Delaware"                 ) echo "DE";;
        "Missouri"                 ) echo "MO";;
        "Tennessee"                ) echo "TN";;
        "District of Columbia"     ) echo "DC";;
        "Montana"                  ) echo "MT";;
        "Texas"                    ) echo "TX";;
        "Florida"                  ) echo "FL";;
        "Nebraska"                 ) echo "NE";;
        "Trust Territories"        ) echo "TT";;
        "Georgia"                  ) echo "GA";;
        "Nevada"                   ) echo "NV";;
        "Utah"                     ) echo "UT";;
        "Guam"                     ) echo "GU";;
        "New Hampshire"            ) echo "NH";;
        "Vermont"                  ) echo "VT";;
        "Hawaii"                   ) echo "HI";;
        "New Jersey"               ) echo "NJ";;
        "Virginia"                 ) echo "VA";;
        "Idaho"                    ) echo "ID";;
        "New Mexico"               ) echo "NM";;
        "Virgin Islands"           ) echo "VI";;
        "Illinois"                 ) echo "IL";;
        "New York"                 ) echo "NY";;
        "Washington"               ) echo "WA";;
        "Indiana"                  ) echo "IN";;
        "North Carolina"           ) echo "NC";;
        "West Virginia"            ) echo "WV";;
        "Iowa"                     ) echo "IA";;
        "North Dakota"             ) echo "ND";;
        "Wisconsin"                ) echo "WI";;
        "Kansas"                   ) echo "KS";;
        "Northern Mariana Islands" ) echo "MP";;
        "Wyoming"                  ) echo "WY";;
    esac
}

# %c city
# %C country
# %r region
# %R region if in the US, country otherwise
ip_location() {
    format=${1:-%c, %r, %C}

    unset str
    str=$(curl -s ipinfo.io | jq)

    if [ -z "$str" ]; then
        echo Unknown
        return
    fi

    city=$(echo "$str" | jq -r .city)
    region=$(echo "$str" | jq -r .region)
    country=$(echo "$str" | jq -r .country)

    if [ "$country" = 'US' ]; then
        format=$(echo "$format" | sed -e 's/%R/%r/')
        region=$(state2abbrev "$region")
    else
        format=$(echo "$format" | sed -e 's/%R/%c/')
    fi

    echo "$format" | sed -e "s/%c/$city/" \
                         -e "s/%r/$region/" \
                         -e "s/%C/$country/" \
                         -e "s/%R/$FOO/"
}

