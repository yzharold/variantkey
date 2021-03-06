context("variantkey")
library(variantkey)

# test-rsidvar.R
# @category   Libraries
# @author     Nicola Asuni <nicola.asuni@genomicsplc.com>
# @copyright  2017-2018 GENOMICS plc
# @license    MIT (see LICENSE)
# @link       https://github.com/genomicsplc/variantkey

x <- rbind(
    list(0, 0x01, 0x0004F44B, 0x00338000, 0x00000001, "08027a2580338000"),
    list(1, 0x09, 0x000143FC, 0x439E3918, 0x00000007, "4800a1fe439e3918"),
    list(2, 0x09, 0x000143FC, 0x7555EB16, 0x0000000B, "4800a1fe7555eb16"),
    list(3, 0x10, 0x000204E8, 0x003A0000, 0x00000061, "80010274003a0000"),
    list(4, 0x10, 0x0002051A, 0x00138000, 0x00000065, "8001028d00138000"),
    list(5, 0x10, 0x00020532, 0x007A0000, 0x000003E5, "80010299007a0000"),
    list(6, 0x14, 0x000256C4, 0x003A0000, 0x000003F1, "a0012b62003a0000"),
    list(7, 0x14, 0x000256C5, 0x00708000, 0x000026F5, "a0012b6280708000"),
    list(8, 0x14, 0x000256CB, 0x63256692, 0x000186A3, "a0012b65e3256692"),
    list(9, 0x14, 0x000256CF, 0x55439803, 0x00019919, "a0012b67d5439803")
)
colnames(x) <- list("item", "chrom", "pos", "refalt", "rsid", "vk")

test_that("MmapBinfile", {
    rsvk <<- MmapBinfile("../../../../c/test/data/rsvk.10.bin")
    expect_that(rsvk$SIZE, equals(120))
    rsvkm <<- MmapBinfile("../../../../c/test/data/rsvk.m.10.bin")
    expect_that(rsvkm$SIZE, equals(120))
    vkrs <<- MmapBinfile("../../../../c/test/data/vkrs.10.bin")
    expect_that(rsvk$SIZE, equals(120))
})

test_that("GetVrRsid", {
    res <- mapply(GetVrRsid, item = unlist(x[,"item"]), MoreArgs = list(src = vkrs$SRC), SIMPLIFY = TRUE, USE.NAMES = FALSE)
    expect_that(res, equals(unlist(x[,"rsid"])))
})

test_that("GetRvVariantKey", {
    res <- mapply(GetRvVariantKey, item = unlist(x[,"item"]), MoreArgs = list(src = rsvk$SRC), SIMPLIFY = TRUE, USE.NAMES = FALSE)
    expect_that(res, equals(unlist(x[,"vk"])))
})

test_that("FindRvVariantKeyByRsid", {
    res <- mapply(FindRvVariantKeyByRsid, rsid = unlist(x[,"rsid"]), MoreArgs = list(src = rsvk$SRC, first = 0, last = 9), SIMPLIFY = TRUE, USE.NAMES = FALSE)
    expect_that(unlist(res[1,]), equals(unlist(x[,"vk"])))
    expect_that(unlist(res[2,]), equals(unlist(x[,"item"])))
})

test_that("FindRvVariantKeyByRsidNotFound", {
    res <- FindRvVariantKeyByRsid(rsvk$SRC, 0, 9, 0xfffffff0)
    expect_that(res$VK, equals("0000000000000000"))
    expect_that(res$FIRST, equals(10))
})

test_that("GetNextRvVariantKeyByRsid", {
    res <- GetNextRvVariantKeyByRsid(rsvk$SRC, 2, 9, 0x00000061)
    expect_that(res$VK, equals("80010274003a0000"))
    expect_that(res$POS, equals(3))
    res <- GetNextRvVariantKeyByRsid(rsvk$SRC, res$POS, 9, 0x00000061)
    expect_that(res$VK, equals("0000000000000000"))
    expect_that(res$POS, equals(4))
})

test_that("FindVrRsidByVariantKey", {
    res <- mapply(FindVrRsidByVariantKey, vk = unlist(x[,"vk"]), MoreArgs = list(src = vkrs$SRC, first = 0, last = 9), SIMPLIFY = TRUE, USE.NAMES = FALSE)
    expect_that(unlist(res[1,]), equals(unlist(x[,"rsid"])))
    expect_that(unlist(res[2,]), equals(unlist(x[,"item"])))
})

test_that("FindVrRsidByVariantKeyNotFound", {
    res <- FindVrRsidByVariantKey(vkrs$SRC, 0, 9, "fffffffffffffff0")
    expect_that(res$RSID, equals(0))
    expect_that(res$FIRST, equals(10))
})

test_that("FindVrChromposRange", {
    res <- FindVrChromposRange(vkrs$SRC, 0, 9, 0x14, 0x000256C5, 0x000256CB)
    expect_that(res$RSID, equals(0x000026F5))
    expect_that(res$FIRST, equals(7))
    expect_that(res$LAST, equals(8))
})

test_that("FindVrChromposRangeNotFound", {
    res <- FindVrChromposRange(vkrs$SRC, 0, 9, 0xff, 0xffffff00, 0xfffffff0)
    expect_that(res$RSID, equals(0))
    expect_that(res$FIRST, equals(10))
    expect_that(res$LAST, equals(9))
})

test_that("FindAllRvVariantKeyByRsid", {
    res <- FindAllRvVariantKeyByRsid(rsvkm$SRC, 0, 9, 0x00000003)
    expect_that(length(res), equals(3))
    expect_that(unlist(res[1]), equals("80010274003a0000"))
    expect_that(unlist(res[2]), equals("8001028d00138000"))
    expect_that(unlist(res[3]), equals("80010299007a0000"))
})

test_that("FindAllRvVariantKeyByRsidNotFound", {
    res <- FindAllRvVariantKeyByRsid(rsvkm$SRC, 0, 9, 0xfffffff0)
    expect_that(length(res), equals(0))
})

test_that("MunmapBinfile", {
    err <- MunmapBinfile(rsvk$SRC, rsvk$FD, rsvk$SIZE)
    expect_that(err, equals(0))
    err <- MunmapBinfile(rsvkm$SRC, rsvkm$FD, rsvkm$SIZE)
    expect_that(err, equals(0))
    err <- MunmapBinfile(vkrs$SRC, vkrs$FD, vkrs$SIZE)
    expect_that(err, equals(0))
})
