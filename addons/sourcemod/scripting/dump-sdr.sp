#include "include/steampawn.inc"

public
Plugin myinfo = {
    name = "Dump SDR info to files",
    author = "ldesgoui",
    description = "",
    version = "0.0.0",
    url = "",
};

public
void OnMapStart() {
    int ip = SteamPawn_GetSDRFakeIP();
    int port = SteamPawn_GetSDRFakePort(0);
    int stvPort = SteamPawn_GetSDRFakePort(1);

    Handle dump = OpenFile("sdr.txt", "w");
    Handle dumpStv = OpenFile("sdr-stv.txt", "w");

    WriteFileLine(dump, "%d.%d.%d.%d:%d", ip >> 24 & 0xff, ip >> 16 & 0xff, ip >> 8 & 0xff, ip & 0xff, port);
    WriteFileLine(dumpStv, "%d.%d.%d.%d:%d", ip >> 24 & 0xff, ip >> 16 & 0xff, ip >> 8 & 0xff, ip & 0xff, stvPort);

    CloseHandle(dump);
    CloseHandle(dumpStv);
}
