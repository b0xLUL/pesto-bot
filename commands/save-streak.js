import { MessageFlags } from "discord.js"

export const name = "save-streak"

export async function run(client, interaction) {
    interaction.reply({
        content: "https://cdn.pestoverse.world/yunya/save-streak.png"
    })
}
