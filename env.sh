#!/bin/bash

# This is a script that takes a .json file and converts it into
# .env file. The .json file comes from Firabase and is of the following 
# format:
# {
#  "type"="service_account"
#  "project_id"="some_id"
#  "private_key_id"="some_key_id"
#  "private_key"="some_key"
#  "client_email"="some_email"
#  "client_id"="some_client_id"
#  "auth_uri"="some_auth_uri"
#  "token_uri"="some_token_uri"
#  "auth_provider_x509_cert_url"="some_cert_url_auth"
#  "client_x509_cert_url"="some_cert_url_client"
# }

usage() {
    echo "Usage: ./env.sh <path to your .json file>"
    exit 1
}

if [ $# -ne 1 ]
then
    usage
fi

content=$(cat $1)
alter=0
hold=0
output=""

prepend=$(sed -n '1,23p' .env.example)

printf "$prepend\n" >> .env

if [ -d "../RocketMeet-mailer" ]
then
    prepend=$(sed -n '1,11p' ../RocketMeet-mailer/.env.example)
    printf "$prepend\n" >> ../RocketMeet-mailer/.env
fi

for word in $content
do
    word=$(echo $word | tr -d '"')
    word=$(echo $word | tr -d ':')
    word=$(echo $word | tr -d ',')
    
    if [ "$word" = "-----BEGIN" ]
    then
        hold=1
        equals="="
        output=$output$equals
    fi

    if [ "$word" = "client_email" ]
    then
        hold=0
        /bin/echo -E $output >> .env
        if [ -d "../RocketMeet-mailer" ]
        then
            /bin/echo -E $output >>  ../RocketMeet-mailer/.env
        fi
        output=$(echo $word | tr '[a-z]' '[A-Z]')
        continue
    fi

    if [ $hold -eq 1 ]
    then
        space=" "
        output=$output$space$word
    fi
    
    if [ "$word" != "}" -a "$word" != "{" -a $hold -eq 0 ]    
    then
        if [ $alter -eq 1 ]
        then
            alter=0
            equals="="
            output=$output$equals$word
            echo $output >> .env
            if [ -d "../RocketMeet-mailer" ]
            then
                echo -E $output >>  ../RocketMeet-mailer/.env
            fi
            output=""
        else
            alter=1
            word=$(echo $word | tr '[a-z]' '[A-Z]')
            output=$output$word
        fi
    fi
done
