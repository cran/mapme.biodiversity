test_that("emissions works", {
  x <- read_sf(system.file("extdata", "gfw_sample.gpkg",
    package = "mapme.biodiversity"
  ))

  gfw_treecover <- rast(list.files(
    system.file("res", "gfw_treecover", package = "mapme.biodiversity"),
    pattern = ".tif$", full.names = TRUE
  ))

  gfw_lossyear <- rast(list.files(
    system.file("res", "gfw_lossyear", package = "mapme.biodiversity"),
    pattern = ".tif$", full.names = TRUE
  ))

  gfw_emissions <- rast(list.files(
    system.file("res", "gfw_emissions", package = "mapme.biodiversity"),
    pattern = ".tif$", full.names = TRUE
  ))

  years <- 2000:2005
  min_size <- 1
  min_cover <- 10
  te <- calc_treecoverloss_emissions(years, min_size, min_cover)
  expect_true(is.null(te(x, gfw_treecover, gfw_lossyear, NULL)))
  result <- te(x, gfw_treecover, gfw_lossyear, gfw_emissions)
  expect_silent(.check_single_asset(result))
  expect_snapshot(result$value)

  tea <- calc_treecover_area_and_emissions(years, min_size, min_cover)
  stats_treeloss <- tea(x, gfw_treecover, gfw_lossyear, gfw_emissions)
  stats_treeloss <- stats_treeloss[stats_treeloss$variable == "emissions", ]
  expect_equal(result$value, stats_treeloss$value, tolerance = 1e-4)

  # test that emissions and forest loss are returned as 0 if now loss occurs
  gfw_lossyear[gfw_lossyear == 3] <- 1
  stats_treeloss <- te(x, gfw_treecover, gfw_lossyear, gfw_emissions)
  expect_equal(stats_treeloss$value[stats_treeloss$datetime == "2003-01-01"], 0)

  years <- 2023:2024
  tea <- calc_treecover_area_and_emissions(years, min_size, min_cover)
  expect_equal(nrow(tea(x, gfw_treecover, gfw_lossyear, gfw_emissions)), 2)

  years <- 2024:2025
  tea <- calc_treecover_area_and_emissions(years, min_size, min_cover)
  expect_true(is.null(tea(x, gfw_treecover, gfw_lossyear, gfw_emissions)))
})
