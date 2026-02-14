Config = {}

Config.Framework = 'auto' -- auto | open | esx | qbcore
Config.Command = 'mechanictablet'
Config.DefaultKeybind = 'F6'
Config.AllowedJobs = {
    open = { 'mechanic' },
    esx = { 'mechanic' },
    qbcore = { 'mechanic' }
}

Config.Locale = {
    title = 'Mechanic Tablet',
    statusOnline = 'Online',
    statusOffline = 'Offline',
    noVehicle = 'No vehicle nearby.',
    noPermission = 'You are not allowed to use the mechanic tablet.',
    inspected = 'Vehicle condition inspected.',
    repaired = 'Vehicle repaired.',
    cleaned = 'Vehicle cleaned.',
    alreadyClean = 'Vehicle is already clean.'
}
