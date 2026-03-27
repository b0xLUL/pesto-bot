export const name = "bibicheck"

export async function run(client, interaction) {

    await interaction.deferReply();

    //try to get the streaminformation from the Twitch API
    try {
        const response = await fetch("https://api.twitch.tv/helix/streams?user_login=bibi_fiore&type=all", {
            method: "GET",
            headers: {
                "Authorization": `Bearer ${process.env.TWITCH_OAUTH_TOKEN}`, //this token expires, need to find a solution for automated refreshes/retrieval
                "Client-Id": process.env.TWITCH_CLIENT_ID,
            }
        })

        if(!response.ok) {
            throw new Error(`Response status of Twitch API: ${response.status}`)
        }
        
        console.log(response)
        
        const responseJson = await response.json();
        const livestatus = responseJson.data.length > 0 ? 'live' : 'offline'

        if(livestatus === 'live') {
            await interaction.editReply({
                content: "bb is currently live! Go join the stream! <:yuniiPog:1281948035181711400>"
            })
        } else {
            await interaction.editReply({
                content: "bb is currently offline. We will patiently wait... <:sit:1107273238385528902>"
            })
        }


    } catch (err) {
        console.error(err);
        await interaction.editReply({
            content: "Something went wrong!",
        });
    }
}

async function refreshTwitchOauthToken() {
    
}